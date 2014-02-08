Red/System [
	Title:		"Textures OpenGL example"
	Author:		"Kaj de Vos"
	Rights: {
		Copyright (c) 2012,2013 Kaj de Vos
		Ported from the C program written by Brian Paul.
	}
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red/System >= 0.2.5
		%C-library/ANSI.reds
		%OpenGL/OpenGL.reds
	}
	Purpose: {
		This is a simple OpenGL example. It shows two spinning textures.
	}
	Tabs:		4
]


#include %../../C-library/ANSI.reds
#include %../OpenGL.reds

#define display-size [640 480]  ; 320 240


width:	8
height:	8


colors: declare struct! [
	part-1-1	[integer!]
	part-1-2	[integer!]
	part-1-3	[integer!]
	part-2-1	[integer!]
	part-2-2	[integer!]
	part-2-3	[integer!]
]
array: as pointer! [integer!] colors
array/1: FFh
array/5: FFh


chars: make 2  width * height

chars/13: as-byte 1
chars/20: as-byte 1
chars/21: as-byte 1
chars/29: as-byte 1
chars/37: as-byte 1
chars/45: as-byte 1
chars/52: as-byte 1
chars/53: as-byte 1
chars/54: as-byte 1

chars/76: as-byte 2
chars/77: as-byte 2
chars/83: as-byte 2
chars/86: as-byte 2
chars/94: as-byte 2
chars/101: as-byte 2
chars/108: as-byte 2
chars/115: as-byte 2
chars/116: as-byte 2
chars/117: as-byte 2
chars/118: as-byte 2


objects: declare struct! [
	texture-1	[unsigned!]
	texture-2	[unsigned!]
]
textures: as pointer! [integer!] objects


angle: 5.0
count: 0
which: 1


with gl [

	bind-image: function [
		object		[integer!]
		image		[integer!]
		/local texture color char cell  i j
	][
		texture: allocate width * height * 3

		bind-texture texture-2D' object

		color: (as pointer! [integer!] colors) + (image * 3)
		image: image * width * height
		i: 0

		until [
			j: 0
			char: chars + image + (height - i - 1 * width)
			cell: texture + (i * width * 3)

			until [
				either char/value = as-byte 0 [  ; White
					cell/1: as-byte FFh
					cell/2: as-byte FFh
					cell/3: as-byte FFh
				][
					cell/1: as-byte color/1
					cell/2: as-byte color/2
					cell/3: as-byte color/3
				]
				char: char + 1
				cell: cell + 3
				j: j + 1
				j = width
			]
			i: i + 1
			i = height
		]
		texture-image-2D	texture-2D' 0 3  width height  0 RGB' gl-byte! texture
		texture-parameter-i	texture-2D' texture-min-filter' nearest'
		texture-parameter-i	texture-2D' texture-mag-filter' nearest'
		texture-parameter-i	texture-2D' texture-wrap-s' repeat'
		texture-parameter-i	texture-2D' texture-wrap-t' repeat'
	]

	setup: does [
		enable depth-test'

		; Set up texturing
		texture-env-i texture-env' texture-env-mode' decal'
		hint perspective-correction-hint' fastest'

		; Generate texture object IDs
		make-textures 2 textures
		bind-image textures/1 0
		bind-image textures/2 1
	]

	reshape: function ["New window size or exposure"
		width		[integer!]
		height		[integer!]
	][
		view-port 0 0  width height
		matrix-mode projection'
		load-identity
;		ortho   -3.0 3.0  -3.0 3.0  -10.0 10.0
		frustum -2.0 2.0  -2.0 2.0    6.0 20.0
		matrix-mode model-view'
		load-identity
		translate 0.0 0.0 -8.0
	]

	draw: function [
		/local index
	][
		clear color-buffer-bit or depth-buffer-bit

		color-3D 1.0 1.0 1.0

		; Draw first polygon

		push-matrix

		translate	-1.0 0.0 0.0
		rotate angle 0.0 0.0 1.0
		bind-texture texture-2D' textures/which

		enable texture-2D'
		begin quads'
		texture-place-2D	 0.0  0.0
		vertex-2D			-1.0 -1.0
		texture-place-2D	 1.0  0.0
		vertex-2D			 1.0 -1.0
		texture-place-2D	 1.0  1.0
		vertex-2D			 1.0  1.0
		texture-place-2D	 0.0  1.0
		vertex-2D			-1.0  1.0
		end
		disable texture-2D'

		pop-matrix

		; Draw second polygon

		push-matrix

		translate 1.0 0.0 0.0
		rotate  angle - 90.0  0.0 1.0 0.0
		index: which xor 3
		bind-texture texture-2D' textures/index

		enable texture-2D'
		begin quads'
		texture-place-2D	 0.0  0.0
		vertex-2D			-1.0 -1.0
		texture-place-2D	 1.0  0.0
		vertex-2D			 1.0 -1.0
		texture-place-2D	 1.0  1.0
		vertex-2D			 1.0  1.0
		texture-place-2D	 0.0  1.0
		vertex-2D			-1.0  1.0
		end
		disable texture-2D'

		pop-matrix
	]

]

on-key: function [
	key			[integer!]
	mask		[enum!]
	return:		[logic!]
][
	yes
]

with three-D [

	idle: does [
		angle: angle + 2.0
		count: count + 1

		if count = 5 [
			count: 0
			which: which xor 3  ; 2#{11}
		]

		draw
		three-D/swap
	]

	view display-size "Textures"

]
