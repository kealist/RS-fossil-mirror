Red/System [
	Title:		"PicoGL framework for OpenGL"
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
		PicoGL
		%SDL/SDL.reds
		%OpenGL/TinyGL.reds
		%OpenGL/OS-Mesa.reds
	}
	Tabs:		4
]


#include %../../SDL/SDL.reds


#switch OS [
	Windows		[#define GL-library "libPicoGL-0.dll"]  ; TODO: check this
	MacOSX		[#define GL-library "libPicoGL.dylib"]  ; TODO: check this
	#default	[#define GL-library "libPicoGL.so.0"]
]
gl: context [#include %../TinyGL.reds]

#define OS-Mesa-library GL-library


three-D: context [with sdl [

	; Types

	context-3D!: alias opaque!


	#import [GL-library cdecl [
		make-context: "sdl_glXCreateContext" [
			return:			[context-3D!]
		]
		end-context: "sdl_glXDestroyContext" [
			context			[context-3D!]
		]
		make-current: "sdl_glXMakeCurrent" [
			surface			[surface!]
			context			[context-3D!]
			return:			[integer!]
		]

;		_do-events: "ui_loop" [						"Enter event loop."
;			argc			[integer!]
;			argv			[string-reference!]
;			name			[c-string!]
;			return:			[integer!]
;		]

		swap: "sdl_glXSwapBuffers" [				"Swap OpenGL screen content."
		]
	]]


	; Higher level interface


	log-error: function ["Log current SDL error."
	][
		print-wide ["Error:" form-error newline]
	]

	view: function ["Make and show a screen, start event loop."
		width			[integer!]
		height			[integer!]
		title			[c-string!]  ; "UTF-8"
		return:			[logic!]
		/local ok? screen context event continue?
	][
		ok?: no  ; Presume failure

		either begin with-video [
			screen: set-video-mode width height 16  hardware-surface or double-buffer

			either as-logic screen [
				set-window-caption title title
				context: make-context

				either as-logic context [
					either zero? make-current screen context [
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
						print-line "Error: failed to activate GL context"
					]
					end-context context
				][
					print-line "Error: failed to create GL context"
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
