Red [
	Title:		"REBOL 3 extension example"
	Type:		'library
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2012,2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red >= 0.4.1
		REBOL 3 > 2.101
		%REBOL-3/extension.reds
	}
	Purpose: {
		This is a simple example of a REBOL 3 extension, written in Red.
	}
	Example: {
		r3
		; Windows:
		import %hello-REBOL-3-extension.dll
		; Other:
		import %./hello-REBOL-3-extension.so
		hello
	}
	Tabs:		4
]


do-hello: does [
	print "Hello Red REBOL extension!"
]


#system-global [

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
				export hello: command ["Print hello from a Red REBOL extension."]
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
		][
			switch command [
			0 [	; hello
				#call [do-hello]

				result-unset
			]
			default [
				error-no-command
			]]
		]

	]

	#export cdecl [RX_Init RX_Quit RX_Call]

]
