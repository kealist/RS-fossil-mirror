Red/System [
	Title:		"SDL framework for OpenGL through OS-Mesa"
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
		Mesa3D
		%SDL/SDL.reds
		%OpenGL/GL.reds
		%OpenGL/OS-Mesa.reds
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
		#define GL-library		"libGL.dylib"
		#define OS-Mesa-library	"libOSMesa.dylib"  ; TODO: check this
	]
	Syllable [
		#define OS-Mesa-library	"libOSMesa.so.7"
		#define GL-library		OS-Mesa-library
	]
	#default [  ; Ubuntu
		#define GL-library		"libGL.so.1"
		#define OS-Mesa-library	"libOSMesa.so.6"
	]
]

gl: context [#include %../GL.reds]

#include %../OS-Mesa.reds


three-D: context [with [osmesa sdl] [

	log-error: function ["Log current SDL error."
	][
		print-wide ["Error:" form-error newline]
	]


	screen: as surface! 0
	buffer: as surface! 0
	ok?: yes


	; Public interface

	swap: function ["Swap OpenGL screen content."
	][
		gl/finish

		unless all [
			blit buffer null screen null
			flip screen
		][
			ok?: no  ; Failure
		]
	]

	view: function ["Make and show a screen, start event loop."
		width			[integer!]
		height			[integer!]
		title			[c-string!]  ; "UTF-8"
		return:			[logic!]
		/local context event continue?
	][
		ok?: no  ; Presume failure

		either begin with-video [
			screen: set-video-mode width height 0  software-surface

			either as-logic screen [
				set-window-caption title title
				context: make-context-with gl/RGBA'  16 0 0  null

				either as-logic context [
					buffer: make-RGB-surface software-surface  width height 32  FFh FF00h 00FF0000h 0

					either as-logic buffer [
						either make-current context buffer/pixels gl/gl-byte! width height [
							pixel-store y-up'  as variant! no

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
							print-line "Error: failed to activate OS-Mesa context"
						]
						free-surface buffer
					][
						print-line "Error: failed to create SDL buffer surface"
					]
					end-context context
				][
					print-line "Error: failed to create OS-Mesa context"
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
