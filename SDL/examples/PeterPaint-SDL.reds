Red/System [
	Title:		"PeterPaint SDL example"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2014 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red/System >= 0.2.5
		%C-library/ANSI.reds
		%SDL/SDL.reds
	}
	Purpose: {
		This is a very simple drawing program. It is written on top of SDL,
		so it is very portable to multiple operating platforms.
		It can load an existing BMP image if you pass it as a parameter
		on the command line.
		The first version of PeterPaint was written shortly before the
		birthday of my friend Peter Busser and is named in his honour.
	}
	Example:	"PeterPaint-SDL sample.bmp"
	Tabs:		4
]


#include %../../C-library/ANSI.reds
#include %../SDL.reds


with sdl [

	current: version
	print-line ["SDL version: "
		as-integer current/major  #"."
		as-integer current/minor  #"."
		as-integer current/patch
	]


	log-error: does [  ; Log current SDL error.
		print-line ["Error: " form-error]
	]


	; Colour to draw with:

	red:	#"^(FF)"
	green:	#"^(FF)"
	blue:	#"^(FF)"


	argument:		get-argument 1
	file:			as-handle 0

	screen:			as surface! 0

	image:			as surface! 0
	rectangle:		declare rectangle!

	event:			declare event!
	mouse-event:	as mouse-motion-event! 0

	either begin with-video [
		screen: set-video-mode 640 480  32  software-surface

		either null? screen [
			log-error
		][
			; If a program parameter is given, load it as a BitMaP file

			if as-logic argument [
;				file: open-read-binary argument  ; FIXME
				file: open argument "rb"
				end-argument argument

				either null? file [
					log-error
				][
					image: load-bmp file yes

					either null? image [
						log-error
					][
						; Squash two 16 bits values in 32 bits space
						rectangle/x-y: 10 << 16 or 20
						rectangle/width-height: image/height << 16 or image/width

						either blit image null screen rectangle [
							update-rectangle screen  20 10  image/width image/height
						][
							log-error
						]
						free-surface image
					]
				]
			]

			; Enter the drawing loop until the window close button is clicked

			while [all [
				await-event event
				event/type <> as-byte quit!
			]][
				; Look for mouse events

				if event/type = as-byte mouse-moved! [
					mouse-event: as mouse-motion-event! event

					; Draw when a mouse button is pressed

					if as-logic mouse-event/pressed [
						unless plot screen
							mouse-event/x-y and FFFFh  ; Clean 16 bits value
							mouse-event/x-y >>> 16  ; Extract 16 bits value
							red green blue
						[
							log-error
						]
					]
				]
			]
		]

		end
	][
		log-error
	]

]
