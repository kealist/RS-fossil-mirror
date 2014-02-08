Red/System [
	Title:		"SDL framework for OpenGL"
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
		Red/System >= 0.2.5
		SDL
		OpenGL
		%SDL/SDL.reds
		%OpenGL/GL.reds
	}
	Tabs:		4
]


#include %../../SDL/SDL.reds

#switch OS [
	Windows [
		#define GL-library		"opengl32.dll"
		#define OS-Mesa-library	"OSMesa32.dll"  ; TODO: check this
	]
	MacOSX [
		#define GL-library		"libGL.dylib"  ; /opt/X11/lib/
		#define OS-Mesa-library	"libOSMesa.dylib"  ; TODO: check this
	]
	#default [  ; Ubuntu
		#define GL-library		"libGL.so.1"
		#define OS-Mesa-library	"libOSMesa.so.6"
	]
]
gl: context [#include %../GL.reds]


three-D: context [with sdl [

	log-error: function ["Log current SDL error."
	][
		print-wide ["Error:" form-error newline]
	]


	; Public interface

	swap: function ["Swap OpenGL screen content."
	][
		gl/flush
;		gl/finish  ; Causes CPU monopolisation on Linux
		sdl/swap
	]

	view: function ["Make and show a screen, start event loop."
		width			[integer!]
		height			[integer!]
		title			[c-string!]  ; "UTF-8"
		return:			[logic!]
		/local ok? screen event continue?
	][
		ok?: no  ; Presume failure

		either begin with-video [
			; Seems not to be needed on Linux, and not to work on Windows...
;			set-gl swap-control 1
;			set-gl gl-double-buffer  as variant! yes

			screen: set-video-mode width height 0  opengl

			either as-logic screen [
				set-window-caption title title
				setup
				reshape width height

				; Enter the rendering loop until the window close button is activated

				event: declare event!
				continue?: yes
				ok?: yes  ; So far so good

				while [
					while [poll-event event] [
						switch as-integer event/type [
							quit! [
								continue?: no
							]
							default []
						]
					]
					continue?
				][
					idle
				]
			][
				log-error
			]
			end
		][
			log-error
		]
		ok?
	]

]]
