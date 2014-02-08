Red/System [
	Title:		"REBOL 3 extension example"
	Type:		'library
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2012,2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red/System >= 0.4.1
		REBOL 3 > 2.101
		%REBOL-3/extension.reds
	}
	Purpose: {
		This is a simple example of a REBOL 3 extension, written in Red/System.
	}
	Example: {
		r3
		; Windows:
		import %hello-REBOL-3-extension.dll
		; Other:
		import %./hello-REBOL-3-extension.so
		version
		platform
		hello-symbol
		hello
		do-hello
		increment 2
		i: 0  do-increment-i
	}
	Tabs:		4
]


#include %../extension.reds


with rebol [

	RX_Init: function [
		options			[integer!]
		library			[rebol!]
		return:			[c-string!]
	][
		interface/value: library
		{
			REBOL [
				Title: "Hello REBOL Extension"
				Name: hello-extension
				Type: extension
			]
			export version:			command ["Return REBOL version."]
			export platform:		command ["Return operating platform."]
			export hello-symbol:	command [{Find symbol ID of the word "hello".}]
			export hello:			command ["Print hello from a Red/System REBOL extension."]
			export do-hello:		command ["Let REBOL print hello from a Red/System REBOL extension."]
			export increment:		command ["Return incremented integer."
				number [integer!]
			]
			export do-increment-i:	command ["Increment variable i."]
		}
	]

	RX_Quit: function [
		options			[integer!]
		return:			[integer!]
	][
		0
	]

	RX_Call: function [
		command			[integer!]
		arguments		[arguments!]
		data			[binary!]
		return:			[result!]
		/local rebol types argument tuple integer
	][
		rebol: interface/value

		types: as tuple! arguments
		argument: (as pointer! [value!] arguments) + 1
		tuple: as tuple! argument
		integer: as rebol-integer! argument

		switch command [
		0 [	; version
;			integer/high: 0
			; WARN: REBOL should never return more than 8 bytes:
			rebol/get-version tuple

			types/first: as-byte type-tuple
			result-value
		]
		1 [	; platform
			; WARN: REBOL should never return more than 8 bytes:
			rebol/get-version tuple

			tuple/count: as-byte 2
			tuple/first: tuple/fourth
			tuple/second: tuple/fifth

			types/first: as-byte type-tuple
			result-value
		]
		2 [	; hello-symbol
			integer/low: rebol/map-word "hello"
			integer/high: 0

			types/first: as-byte type-integer
			result-value
		]
		3 [	; hello
			rebol/print "Hello Red/System REBOL extension!^/"
			result-unset
		]
		4 [	; do-hello
			types/first: as-byte rebol/do-string {print "Hello"} 0 argument
			result-value
		]
		5 [	; increment
			integer/low: integer/low + 1
			result-value
		]
		6 [	; do-increment-i
			types/first: as-byte rebol/do-string "i: i + 1" 0 argument
			result-value
		]
		default [
			error-no-command
		]]
	]

]

#export cdecl [RX_Init RX_Quit RX_Call]
