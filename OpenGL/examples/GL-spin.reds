Red/System [
	Title:		"Spinning box OpenGL example"
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
		%OpenGL/OpenGL.reds
	}
	Purpose: {
		This is a simple OpenGL example.
		It shows a spinning box drawn with coloured lines.
	}
	Tabs:		4
]


#include %../OpenGL.reds

#define display-size [640 480]  ; 320 240


step:		5.0
scaling:	1.0

x-rotation:	0.0
x-step:		0.0
y-rotation:	0.0
y-step:		0.0
z-rotation:	0.0
z-step:		0.0


object: 0  ; unsigned!

with gl [

	make-object: function [
		return:		[unsigned!]
		/local		list
	][
		list: make-lists 1

		begin-list list compile'

		begin line-loop'
		color-3D   1.0  1.0  1.0
		vertex-3D  1.0  0.5 -0.4
		color-3D   1.0  0.0  0.0
		vertex-3D  1.0 -0.5 -0.4
		color-3D   0.0  1.0  0.0
		vertex-3D -1.0 -0.5 -0.4
		color-3D   0.0  0.0  1.0
		vertex-3D -1.0  0.5 -0.4
		end

		color-3D 1.0 1.0 1.0

		begin line-loop'
		vertex-3D  1.0  0.5  0.4
		vertex-3D  1.0 -0.5  0.4
		vertex-3D -1.0 -0.5  0.4
		vertex-3D -1.0  0.5  0.4
		end

		begin lines'
		vertex-3D  1.0  0.5 -0.4  vertex-3D  1.0  0.5  0.4
		vertex-3D  1.0 -0.5 -0.4  vertex-3D  1.0 -0.5  0.4
		vertex-3D -1.0 -0.5 -0.4  vertex-3D -1.0 -0.5  0.4
		vertex-3D -1.0  0.5 -0.4  vertex-3D -1.0  0.5  0.4
		end

		end-list

		list
	]

	setup: does [
		object: make-object

		cull-face back'
;		enable cull-face'
		disable dither'
		shade-model flat'
;		enable depth-test'

		x-rotation: 0.0
		y-rotation: 0.0
		z-rotation: 0.0

		x-step: step
		y-step: 0.0
		z-step: 0.0
	]

	reshape: function [
		width		[integer!]
		height		[integer!]
	][
		view-port 0 0  width height
		matrix-mode projection'
		load-identity
		frustum -1.0 1.0  -1.0 1.0  5.0 15.0
		matrix-mode model-view'
	]

	draw: does [
		clear color-buffer-bit

		push-matrix

		translate 0.0 0.0 -10.0
		scale scaling scaling scaling

		case [
			x-step <> 0.0	[rotate x-rotation 1.0 0.0 0.0]
			y-step <> 0.0	[rotate y-rotation 0.0 1.0 0.0]
			yes				[rotate z-rotation 0.0 0.0 1.0]
		]

		call-list object

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
		x-rotation: x-rotation + x-step
		y-rotation: y-rotation + y-step
		z-rotation: z-rotation + z-step

		either x-rotation >= 360.0 [
			x-rotation:	0.0
			x-step:		0.0
			y-step:		step
		][
			either y-rotation >= 360.0 [
				y-rotation:	0.0
				y-step:		0.0
				z-step:		step
			][
				if z-rotation >= 360.0 [
					z-rotation:	0.0
					z-step:		0.0
					x-step:		step
				]
			]
		]

		draw
		three-D/swap
	]

	view display-size "Spin"

]
