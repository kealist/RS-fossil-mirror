Red/System [
	Title:		"SDL Binding"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2013 Kaj de Vos. All rights reserved."
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
		SDL 1.2
		%common/common.reds
	}
	Tabs:		4
]


#include %../common/common.reds


sdl: context [

	version!: alias struct! [
		major					[byte!]
		minor					[byte!]
		patch					[byte!]
	]

	#enum begin-mask! [
		with-all:				0000FFFFh
		with-timer:				00000001h
		with-audio:				00000010h
		with-video:				00000020h
		with-cdrom:				00000100h
		with-joystick:			00000200h
		with-no-parachute:		00100000h  ; Don't catch fatal signals
		with-event-thread:		01000000h  ; Not supported on all OS's
	]


	; Events

	key!: alias struct! [
		scancode				[byte!]
		symbol					[enum!]
		modifiers				[enum!]
		unicode					[unsigned16!]
	]

	#enum event-type! [
		focus!:					1
		key-down!
		key-up!
		mouse-moved!
		mouse-button-down!
		mouse-button-up!
		axis-motion!
		ball-motion!
		hat-motion!
		button-down!
		button-up!
		quit!
		system-event!
		resize!:				16
		expose!
	]

	event!: alias struct! [
		type					[byte!]  ; event-type!

		pad-1					[integer!]
		pad-2					[integer!]
		pad-3					[integer!]
	]
	keyboard-event!: alias struct! [
		type					[byte!]
		device					[byte!]
		pressed?				[byte!]

		key						[key!]
	]
	mouse-motion-event!: alias struct! [
		type					[byte!]
		device					[byte!]
		pressed					[byte!]

;		x						[unsigned16!]
;		y						[unsigned16!]
			x-y					[integer!]

;		relative-x				[integer16!]
;		relative-y				[integer16!]
			relative-x-y		[integer!]
	]
	mouse-button-event!: alias struct! [
		type					[byte!]
		device					[byte!]
		button					[byte!]
		pressed?				[byte!]

;		x						[unsigned16!]
;		y						[unsigned16!]
			x-y					[integer!]
	]


	; Graphics

	#enum video-mode-mask! [
		software-surface
		hardware-surface:		00000001h
		async-blit:				00000004h

		any-format:				10000000h
		hardware-palette:		20000000h
		double-buffer:			40000000h
		full-screen:			80000000h
		opengl:					00000002h
		;opengl-blit:			0000000Ah  ; Deprecated
		resizable:				00000010h
		no-frame:				00000020h
	]

	pixel-format!: alias struct! [
		palette					[handle!]
		bits-per-pixel			[byte!]
		bytes-per-pixel			[byte!]

		red-loss				[byte!]
		green-loss				[byte!]
		blue-loss				[byte!]
		alpha-loss				[byte!]

		red-shift				[byte!]
		green-shift				[byte!]
		blue-shift				[byte!]
		alpha-shift				[byte!]

		red-mask				[unsigned32!]
		green-mask				[unsigned32!]
		blue-mask				[unsigned32!]
		alpha-mask				[unsigned32!]

		color-key				[unsigned32!]
		alpha					[byte!]
	]

	rectangle!: alias struct! [
;		x						[integer16!]
;		y						[integer16!]
			x-y					[integer!]

;		width					[unsigned16!]
;		height					[unsigned16!]
			width-height		[integer!]
	]

	surface!: alias struct! [
		flags					[unsigned32!]
		format					[pixel-format!]
		width					[integer!]
		height					[integer!]
		pitch					[unsigned16!]
		pixels					[binary!]
		offset					[integer!]
		hardware-data			[handle!]

;		clip-rectangle			[rectangle!]
			clip-x-y			[integer!]
			clip-width-height	[integer!]
		unused					[unsigned32!]

		locked					[unsigned32!]
		blit-map				[handle!]
		format-version			[unsigned!]
		reference-count			[integer!]
	]


	; OpenGL

	#enum attribute! [
		red-size
		green-size
		blue-size
		alpha-size

		buffer-size
		gl-double-buffer

		depth-size
		stencil-size

		accum-red-size
		accum-green-size
		accum-blue-size
		accum-alpha-size

		stereo

		multi-sample-buffers
		multi-sample-samples

		accelerated-visual
		swap-control
	]


	; Sound

	audio-spec!: alias struct! [
		frequency				[integer!]

;		format					[unsigned16!]
			format-1			[byte!]
			format-2			[byte!]
		channels				[byte!]
		silence					[byte!]

		samples					[unsigned16!]
;		padding					[unsigned16!]

		size					[unsigned32!]

;		callback				[function! [user-data [handle!] stream [binary!] size [integer!]]]
		callback				[integer!]
		user-data				[handle!]
	]

	audio-conversion!: alias struct! [
		needed?					[logic!]

;		source-format			[unsigned16!]
;		target-format			[unsigned16!]
			formats				[integer!]

		rate-increment			[float!]

		data					[binary!]
		source-size				[integer!]
		target-size				[integer!]
		size-multiple			[integer!]

		size-ratio				[float!]

;		filter					[function! [conversion [audio-conversion!] format [unsigned16!]]]
		filter-1				[integer!]
		filter-2				[integer!]
		filter-3				[integer!]
		filter-4				[integer!]
		filter-5				[integer!]
		filter-6				[integer!]
		filter-7				[integer!]
		filter-8				[integer!]
		filter-9				[integer!]
		filter-10				[integer!]
		filter-index			[integer!]
	]

	; Audio format flags (defaults to LSB byte order)
	#enum audio-format-mask! [
		audio-u8:				0008h  ; Unsigned 8-bit samples
		audio-s8:				8008h  ; Signed 8-bit samples
		audio-u16lsb:			0010h  ; Unsigned 16-bit samples
		audio-s16lsb:			8010h  ; Signed 16-bit samples
		audio-u16msb:			1010h  ; As above, but big-endian byte order
		audio-s16msb:			9010h  ; As above, but big-endian byte order
		audio-u16:				audio-u16lsb
		audio-s16:				audio-s16lsb
	]

	#define mix-max-volume		128

	#enum audio-status! [
		audio-stopped
		audio-playing
		audio-paused
	]


	#switch OS [
		Windows		[#define SDL-library "SDL.dll"]
		MacOSX		[#define SDL-library "/Library/Frameworks/SDL.framework/Versions/A/SDL"]
		Syllable	[#define SDL-library "libSDL-1.2.so"]
		#default	[#define SDL-library "libSDL-1.2.so.0"]
	]
	#import [SDL-library cdecl [
		; WARN: SDL header says to use a macro, but we can't
		version: "SDL_Linked_Version" [						"Return SDL version."
			return:				[version!]
		]


		; Error handling

		form-error: "SDL_GetError" [						"Return status message."
			return:				[c-string!]
		]


		; Global setup and teardown

		_begin: "SDL_Init" [								"Set up SDL library."
			flags				[begin-mask!]				"unsigned32!"
			return:				[integer!]
		]
		end: "SDL_Quit" [									"Clean up SDL environment."
		]


		; Events

		await-event: "SDL_WaitEvent" [						"Wait for an event."
			event				[event!]
			return:				[logic!]
		]
		poll-event: "SDL_PollEvent" [						"Poll for an event."
			event				[event!]
			return:				[logic!]
		]


		; Storage


		open: "SDL_RWFromFile" [							"Open file."
			name				[c-string!]
			mode				[c-string!]
			return:				[handle!]
		]


		; Graphics


		; Windows

		set-window-caption: "SDL_WM_SetCaption" [			"Set window title and icon text."
			title				[c-string!]					"UTF-8"
			icon-caption		[c-string!]					"UTF-8"
		]
		get-window-caption: "SDL_WM_GetCaption" [			"Get window title and icon text."
			title				[string-reference!]			"UTF-8"
			icon-caption		[string-reference!]			"UTF-8"
		]


		; Surfaces

		set-video-mode: "SDL_SetVideoMode" [				"Return configured screen surface."
			width				[integer!]
			height				[integer!]
			color-depth			[integer!]
			flags				[video-mode-mask!]			"unsigned32!"
			return:				[surface!]
		]
		make-RGB-surface: "SDL_CreateRGBSurface" [			"Return a new RGB surface."
			flags				[video-mode-mask!]			"unsigned32!"
			width				[integer!]
			height				[integer!]
			color-depth			[integer!]
			red-mask			[unsigned32!]
			green-mask			[unsigned32!]
			blue-mask			[unsigned32!]
			alpha-mask			[unsigned32!]
			return:				[surface!]
		]
		make-RGB-surface-from: "SDL_CreateRGBSurfaceFrom" [	"Return a new RGB surface from pixel data."
			pixels				[binary!]
			width				[integer!]
			height				[integer!]
			color-depth			[integer!]
			pitch				[integer!]
			red-mask			[unsigned32!]
			green-mask			[unsigned32!]
			blue-mask			[unsigned32!]
			alpha-mask			[unsigned32!]
			return:				[surface!]
		]

		_lock-surface: "SDL_LockSurface" [					"Lock surface."
			surface				[surface!]
			return:				[integer!]
		]
		unlock-surface: "SDL_UnlockSurface" [				"Unlock surface."
			surface				[surface!]
		]

		free-surface: "SDL_FreeSurface" [					"Clean up surface."
			surface				[surface!]
		]


		; Display updating

		_flip: "SDL_Flip" [									"Swap screen content."
			screen				[surface!]
			return:				[integer!]
		]
		update-rectangle: "SDL_UpdateRect" [				"Update rectangle on the screen."
			screen				[surface!]
			x					[integer32!]
			y					[integer32!]
			width				[unsigned32!]
			height				[unsigned32!]
		]
		update-rectangles: "SDL_UpdateRects" [				"Update array of rectangles on the screen."
			screen				[surface!]
			count				[integer!]
			rectangles			[rectangle!]
		]


		; Rectangles

		set-clipping: "SDL_SetClipRect" [					"Set clipping rectangle."
			surface				[surface!]
			rectangle			[rectangle!]				"NULL: no clipping"
			return:				[logic!]					"FALSE: no intersecting area"
		]
		get-clipping: "SDL_SetClipRect" [					"Get clipping rectangle."
			surface				[surface!]
			rectangle			[rectangle!]
		]

		_blit: "SDL_UpperBlit" [							"Blit source rectangle to target surface."
			source				[surface!]
			source-rectangle	[rectangle!]
			target				[surface!]
			target-rectangle	[rectangle!]
			return:				[integer!]
		]

		_fill: "SDL_FillRect" [								"Fill rectangle."
			surface				[surface!]
			rectangle			[rectangle!]				"NULL: fill whole surface"
			color				[unsigned32!]
			return:				[integer!]
		]


		map-RGB: "SDL_MapRGB" [								"Map RGB color to pixel value."
			format				[pixel-format!]
			red					[byte!]
			green				[byte!]
			blue				[byte!]
			return:				[unsigned32!]
		]
		map-RGBA: "SDL_MapRGBA" [							"Map RGBA color to pixel value."
			format				[pixel-format!]
			red					[byte!]
			green				[byte!]
			blue				[byte!]
			alpha				[byte!]
			return:				[unsigned32!]
		]


		; OpenGL

		set-gl: "SDL_GL_SetAttribute" [						"Set OpenGL attribute."
			attribute			[attribute!]
			value				[variant!]
			return:				[integer!]
		]
		get-gl: "SDL_GL_GetAttribute" [						"Get OpenGL attribute."
			attribute			[attribute!]
			value				[pointer! [variant!]]
			return:				[integer!]
		]

		swap: "SDL_GL_SwapBuffers" [						"Swap OpenGL screen content."
		]


		; Storage

		load-bmp: "SDL_LoadBMP_RW" [						"Load a BMP image."
			source				[handle!]
			close?				[logic!]
			return:				[surface!]
		]
		_save-bmp: "SDL_SaveBMP_RW" [						"Save a BMP image."
			surface				[surface!]
			target				[handle!]
			close?				[logic!]
			return:				[integer!]
		]


		; Sound


		_open-audio: "SDL_OpenAudio" [						"Determine sound format."
			desired				[audio-spec!]
			obtained			[audio-spec!]
			return:				[integer!]
		]
		close-audio: "SDL_CloseAudio" [						"Close sound device."
		]

		lock-audio: "SDL_LockAudio" [						"Lock sound mixer callback."
		]
		unlock-audio: "SDL_UnlockAudio" [					"Unlock sound mixer callback."
		]

		pause-audio: "SDL_PauseAudio" [						"Pause and start sound."
			pause?				[logic!]
		]
		get-audio-status: "SDL_GetAudioStatus" [			"Get audio status."
			return:				[audio-status!]
		]

		mix-audio: "SDL_MixAudio" [							"Mix sounds."
			target				[binary!]
			source				[binary!]
			size				[unsigned32!]
			volume				[integer!]					"0 - 128"
		]

		_make-audio-conversion: "SDL_BuildAudioCVT" [		"Prepare a sound conversion."
			conversion			[audio-conversion!]
			source-format		[unsigned16!]				"audio-format-mask!"
			source-channels		[byte!]
			source-rate			[integer!]
			target-format		[unsigned16!]				"audio-format-mask!"
			target-channels		[byte!]
			target-rate			[integer!]
			return:				[integer!]
		]
		_convert-audio: "SDL_ConvertAudio" [				"Convert sound format."
			conversion			[audio-conversion!]
			return:				[integer!]
		]


		; Storage

		load-wav: "SDL_LoadWAV_RW" [						"Load a WAV sound."
			source				[handle!]
			close?				[logic!]
			format				[audio-spec!]
			data				[binary-reference!]
			size				[pointer! [integer!]]
			return:				[audio-spec!]
		]
		free-wav: "SDL_FreeWAV" [							"Clean up WAV sound."
			data				[binary!]
		]
	]]


	; Higher level interface


	; Global setup

	begin: function ["Set up SDL library."
		flags				[begin-mask!]  "unsigned32!"
		return:				[logic!]
	][
		zero? _begin flags
	]


	; Graphics


	lock-surface: function ["Lock surface."
		surface				[surface!]
		return:				[logic!]
	][
		zero? _lock-surface surface
	]

	flip: function ["Swap screen content."
		screen				[surface!]
		return:				[logic!]
	][
		zero? _flip screen
	]

	blit: function ["Blit source rectangle to target surface."
		source				[surface!]
		source-rectangle	[rectangle!]
		target				[surface!]
		target-rectangle	[rectangle!]
		return:				[logic!]
	][
		zero? _blit source source-rectangle target target-rectangle
	]

	fill: function ["Fill rectangle."
		surface				[surface!]
		rectangle			[rectangle!]  ; "NULL: fill whole surface"
		color				[unsigned32!]
		return:				[logic!]
	][
		zero? _fill surface rectangle color
	]


	plot: function ["Draw a pixel."
		surface				[surface!]
		x					[integer!]
		y					[integer!]
		red					[byte!]
		green				[byte!]
		blue				[byte!]
		return:				[logic!]
		/local
			format color
			buffer8 buffer32
;			shift
	][
		either zero? _lock-surface surface [
			format: surface/format
			color: map-RGB format red green blue

			switch format/bytes-per-pixel [
			4 [
				buffer32: (as pointer! [integer!] surface/pixels) +
					(surface/pitch and FFFFh / 4 * y) +
					x
				buffer32/value: color
			]
			2 [
				buffer8: surface/pixels +
					(surface/pitch and FFFFh * y) +
					(x * 2)
				buffer8/1: as-byte color and FFh
				buffer8/2: as-byte color >>> 8 and FFh
			]
			3 [
				buffer8: surface/pixels +
					(surface/pitch and FFFFh * y) +
					(x * 3)

;				shift: as-integer format/red-shift / 8
;				buffer8/shift: red
;				shift: as-integer format/green-shift / 8
;				buffer8/shift: green
;				shift: as-integer format/blue-shift / 8
;				buffer8/shift: blue
				buffer8/1: as-byte color and FFh
				buffer8/2: as-byte color >>> 8 and FFh
				buffer8/3: as-byte color >>> 16 and FFh
			]
			1 [
				buffer8: surface/pixels +
					(surface/pitch and FFFFh * y) +
					x
				buffer8/value: as-byte color and FFh
			]]

			unlock-surface surface
			update-rectangle surface x y 1 1

			yes
		][
			no
		]
	]


	; Sound


	open-audio: function ["Determine sound format."
		desired				[audio-spec!]
		obtained			[audio-spec!]  "NULL: automatic conversion"
		return:				[logic!]
	][
		zero? _open-audio desired obtained
	]

	make-audio-conversion: function ["Prepare a sound conversion."
		conversion			[audio-conversion!]
		source-format		[unsigned16!]  "audio-format-mask!"
		source-channels		[byte!]
		source-rate			[integer!]
		target-format		[unsigned16!]  "audio-format-mask!"
		target-channels		[byte!]
		target-rate			[integer!]
		return:				[logic!]
	][
		; WARN: returns "conversion needed?" logic! on success
		not negative? _make-audio-conversion
			conversion
			source-format source-channels source-rate
			target-format target-channels target-rate
	]
	convert-audio: function ["Convert sound format."
		conversion			[audio-conversion!]
		return:				[logic!]
	][
		zero? _convert-audio conversion
	]


	stream!: alias struct! [
;		data				[binary!]
		index				[binary!]
		rest				[integer!]
	]
	fetch-audio: function ["Read sound buffer to be played."
		[cdecl]
		source				[stream!]
		sink				[binary!]
		size				[integer!]
		/local slice
	][
		slice: source/rest
		if slice > size [slice: size]

;		copy-part source/index sink slice
		mix-audio sink source/index slice mix-max-volume

		source/index: source/index + slice
		source/rest: source/rest - slice
	]

]
