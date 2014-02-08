Red/System [
	Title:		"Common part of OpenGL bindings"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2012,2013 Kaj de Vos. All rights reserved."
	License: {
		Redistribution and use in source and binary forms, with or without modification,
		are permitted provided that the following conditions are met:

		    * Redistributions of source code must retain the above copyright notice,
		      this list of conditions and the following disclaimer.
		    * Redistributions in binary form must reproduce the above copyright notice,
		      this list of conditions and the following disclaimer in the documentation
		      and/or other materials provided with the distribution.

		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
		ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
		WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
		DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
		FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
		DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
		SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
		CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
		OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
		OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	}
	Needs: {
		Red/System >= 0.3.2
		%OpenGL/common.reds
	}
	Tabs:		4
]


#enum type! [
	gl-signed-byte!:				1400h
	gl-byte!
	gl-integer16!
	gl-unsigned16!
	gl-integer!
	gl-unsigned!
	gl-float32!
	gl-2-bytes!
	gl-3-bytes!
	gl-4-bytes!
	gl-float64!
]


#include %common.reds


#enum primitive! [
	points'
	lines'
	line-loop'
	line-strip'
	triangles'
	triangle-strip'
	triangle-fan'
	quads'
	quad-strip'
	polygon'
]

#enum attribute! [
	current-bit:					00000001h
	point-bit:						00000002h
	line-bit:						00000004h
	polygon-bit:					00000008h
	polygon-stipple-bit:			00000010h
	pixel-mode-bit:					00000020h
	lighting-bit:					00000040h
	fog-bit:						00000080h
	depth-buffer-bit:				00000100h
	accum-buffer-bit:				00000200h
	stencil-buffer-bit:				00000400h
	view-port-bit:					00000800h
	transform-bit:					00001000h
	enable-bit:						00002000h
	color-buffer-bit:				00004000h
	hint-bit:						00008000h
	eval-bit:						00010000h
	list-bit:						00020000h
	texture-bit:					00040000h
	scissor-bit:					00080000h
	all-attributes-bits:			000FFFFFh
]


#import [GL-library call! [

	begin: "glBegin" [
		type			[primitive!]
	]
	end: "glEnd" []


	shade-model: "glShadeModel" [
		mode			[enum!]
	]
	polygon-mode: "glPolygonMode" [
		face			[integer!]
		mode			[enum!]
	]


	; Vertexes

	vertex-2D-32: "glVertex2f" [
		x				[float32!]
		y				[float32!]
	]

	vertex-3D-32: "glVertex3f" [
		x				[float32!]
		y				[float32!]
		z				[float32!]
	]


	; Colours

	color-3D-32: "glColor3f" [
		red				[float32!]
		green			[float32!]
		blue			[float32!]
	]


	; Matrix

	matrix-mode: "glMatrixMode" [
		mode			[enum!]
	]
	load-identity: "glLoadIdentity" []

	push-matrix: "glPushMatrix" []
	pop-matrix: "glPopMatrix" []

	translate-32: "glTranslatef" [
		x				[float32!]
		y				[float32!]
		z				[float32!]
	]
	scale-32: "glScalef" [
		x				[float32!]
		y				[float32!]
		z				[float32!]
	]
	rotate-32: "glRotatef" [
		angle			[float32!]
		x				[float32!]
		y				[float32!]
		z				[float32!]
	]

	frustum: "glFrustum" [
		left			[float!]
		right			[float!]
		bottom			[float!]
		top				[float!]
		near			[float!]
		far				[float!]
	]


	; Lists

	make-lists: "glGenLists" [
		range			[integer!]
		return:			[unsigned!]
	]
	list?: "glIsList" [
		object			[unsigned!]
		return:			[logic!]
	]

	begin-list: "glNewList" [
		list			[unsigned!]
		mode			[enum!]
	]
	end-list: "glEndList" []

	call-list: "glCallList" [
		list			[unsigned!]
	]


	; Textures

	texture-place-2D-32: "glTexCoord2f" [
		x				[float32!]
		y				[float32!]
	]

	texture-env-i: "glTexEnvi" [
		target			[enum!]
		name			[enum!]
		value			[integer!]
	]

]]


; Higher level interface


; Matrix

translate: function [
	x				[float!]
	y				[float!]
	z				[float!]
][
	translate-32  as-float32 x  as-float32 y  as-float32 z
]

scale: function [
	x				[float!]
	y				[float!]
	z				[float!]
][
	scale-32  as-float32 x  as-float32 y  as-float32 z
]

rotate: function [
	angle			[float!]
	x				[float!]
	y				[float!]
	z				[float!]
][
	rotate-32  as-float32 angle  as-float32 x  as-float32 y  as-float32 z
]
