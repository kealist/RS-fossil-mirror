Red/System [
	Title:		"Common part of OpenGL and GLES bindings"
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
		%common/FPU-configuration.reds
	}
	Tabs:		4
]


#include %../common/FPU-configuration.reds


; Types


#define bit-field!					unsigned!
#define clamp!						float32!


#enum matrix! [
	matrix-mode':					0BA0h
	model-view':					1700h
	projection'
	texture'
]
#enum polygons! [
;	front':							0404h
;	back'
	cw':							0900h
	ccw'
	polygon-mode':					0B40h
	polygon-smooth'
	polygon-stipple'
	edge-flag'
	cull-face'
	cull-face-mode'
	front-face'
	point':							1B00h
	line'
	fill'
	polygon-offset-units':			2A00h
	polygon-offset-point'
	polygon-offset-line'
	polygon-offset-fill':			8037h
	polygon-offset-factor'
]
#enum display-lists! [
	list-mode':						0B30h
	list-base':						0B32h
	list-index'
	compile':						1300h
	compile-and-execute'
]
#enum depth-buffer! [
	never':							0200h
	less'
	equal'
	less-or-equal'
	greater'
	not-equal'
	greater-or-equal'
	always'
	depth-range':					0B70h
	depth-test'
	depth-write-mask'
	depth-clear-value'
	depth-function'
	depth-bits':					0D56h
	depth-component':				1902h
]
#enum lighting! [
;	front-and-back':				0408h
	lighting':						0B50h
	light-model-local-viewer'
	light-model-two-side'
	light-model-ambient'
	shade-model'
	color-material-face'
	color-material-parameter'
	color-material'
	normalize':						0BA1h
	ambient':						1200h
	diffuse'
	specular'
	position'
	spot-direction'
	spot-exponent'
	spot-cutoff'
	constant-attenuation'
	linear-attenuation'
	quadratic-attenuation'
	emission':						1600h
	shininess'
	ambient-and-diffuse'
	color-indexes'
	flat':							1D00h
	smooth'
	light0':						4000h
	light1'
	light2'
	light3'
	light4'
	light5'
	light6'
	light7'
]
#enum buffers! [
	none'
	front-left':					0400h
	front-right'
	back-left'
	back-right'
	front'
	back'
	left'
	right'
	front-and-back'
	aux0'
	aux1'
	aux2'
	aux3'
	dither':						0BD0h
	aux-buffers':					0C00h
	draw-buffer'
	read-buffer'
	double-buffer':					0C32h
	stereo'
	subpixel-bits':					0D50h
	index-bits'
	red-bits'
	green-bits'
	blue-bits'
	alpha-bits'
	color':							1800h
	depth'
	stencil'
	color-index':					1900h
	red':							1903h
	green'
	blue'
	alpha'
	RGB'
	RGBA'
	luminance'
	luminance-alpha'
	bitmap':						1A00h
]
#enum hints! [
	perspective-correction-hint':	0C50h
	point-smooth-hint'
	line-smooth-hint'
	polygon-smooth-hint'
	fog-hint'
	don't-care':					1100h
	fastest'
	nicest'
]
#enum textures! [
	texture-gen-s':					0C60h
	texture-gen-t'
	texture-gen-r'
	texture-gen-q'
	texture-1D':					0DE0h
	texture-2D'
	texture-width':					1000h
	texture-height'
	texture-components':			1003h
	texture-border-color'
	texture-border'
	s':								2000h
	t'
	r'
	q'
	modulate':						2100h
	decal'
	texture-env-mode':				2200h
	texture-env-color'
	texture-env':					2300h
	eye-linear':					2400h
	object-linear'
	sphere-map'
	texture-gen-mode':				2500h
	object-plane'
	eye-plane'
	nearest':						2600h
	nearest-mipmap-nearest':		2700h
	linear-mipmap-nearest'
	nearest-mipmap-linear'
	linear-mipmap-linear'
	texture-mag-filter':			2800h
	texture-min-filter'
	texture-wrap-s'
	texture-wrap-t'
	clamp':							2900h
	repeat'
]


#import [GL-library call! [

	enable: "glEnable" [
		code			[enum!]
	]
	disable: "glDisable" [
		code			[enum!]
	]

	flush: "glFlush" []


	cull-face: "glCullFace" [
		mode			[enum!]
	]


	; Matrix

	view-port: "glViewport" [
		x				[integer!]
		y				[integer!]
		width			[size!]
		height			[size!]
	]


	; Clearing

	clear: "glClear" [
		mask			[bit-field!]
	]
	clear-color: "glClearColor" [
		red				[clamp!]
		green			[clamp!]
		blue			[clamp!]
		alpha			[clamp!]
	]


	; Textures

	make-textures: "glGenTextures" [
		count			[size!]
		textures		[pointer! [unsigned!]]
	]
	remove-textures: "glDeleteTextures" [
		count			[size!]
		textures		[pointer! [unsigned!]]
	]

	bind-texture: "glBindTexture" [
		target			[enum!]
		texture			[unsigned!]
	]
	texture-image-2D: "glTexImage2D" [
		target			[enum!]
		level			[integer!]
		components		[integer!]  ; Internal format
		width			[size!]
		height			[size!]
		border			[integer!]
		format			[enum!]
		type			[type!]
		pixels			[binary!]
	]
	texture-parameter-i: "glTexParameteri" [
		target			[enum!]
		name			[enum!]
		value			[integer!]
	]
	pixel-store-i: "glPixelStorei" [
		name			[enum!]
		value			[integer!]
	]


	; Various

	hint: "glHint" [
		target			[enum!]
		mode			[enum!]
	]

]]
