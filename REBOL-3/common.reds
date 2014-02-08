Red/System [
	Title:		"REBOL 3 Binding"
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
		Red/System > 0.3.2
		REBOL 3 > 2.101
		%common/common.reds
	}
	Tabs:		4
]


; Program arguments:
options!:				alias opaque!


; Polymorphic REBOL value:
#define value!			integer64!

; Command arguments; array of 8 value structures:
arguments!:				alias struct! [item [value!]]

#enum result! [
	result-unset
	result-none
	result-true
	result-false

	result-value
	result-block
	result-error

	error-bad-arguments
	error-no-command
]

; Extension command dispatcher:
#define call! [
	function! [
		command			[integer!]
		arguments		[arguments!]
		data			[binary!]
		return:			[result!]
	]
]


; Extension interface types

#define symbol!			unsigned32!
symbol-array!:			alias struct! [item [symbol!]]

series!:				alias opaque!
context!:				alias opaque!
event!:					alias opaque!
callback!:				alias opaque!

#enum property! [
	series-data			; Data pointer
	series-length		; Data length
	series-size			; Size in units
	series-bytes		; Size in bytes
	series-free			; Free size past tail
]


; REBOL cell types

#enum type! [
	type-end
	type-unset
	type-none
	type-handle
	type-logic
	type-integer
	type-decimal
	type-percent

	type-char:			10
	type-pair
	type-tuple
	type-time
	type-date

	type-word:			16
	type-set-word
	type-get-word
	type-lit-word
	type-refinement
	type-issue

	type-string:		24
	type-file
	type-email
	type-url
	type-tag

	type-block:			32
	type-paren
	type-path
	type-set-path
	type-get-path
	type-lit-path

	type-binary:		40
	type-bitset
	type-vector
	type-image

	type-gob:			47
	type-object
	type-module

	type-max
]

rebol-handle!: alias struct! [
	value				[binary!]
	padding				[integer32!]
]

rebol-integer!: alias struct! [
	low					[unsigned32!]  ; FIXME: reversed for big-endian
	high				[integer32!]
]

decimal!:				alias struct! [value [float!]]

pair!: alias struct! [
	x					[float32!]
	y					[float32!]
]

tuple!: alias struct! [
	count				[byte!]
	first				[byte!]
	second				[byte!]
	third				[byte!]
	fourth				[byte!]
	fifth				[byte!]
	sixth				[byte!]
	seventh				[byte!]
]

image!: alias struct! [
	data				[binary!]
;	width				[unsigned16!]
;	height				[unsigned16!]
		width-height	[unsigned32!]
]

reference!: alias struct! [
	series				[series!]
	index				[unsigned32!]
]


; REBOL core interpreter function table

rebol!: alias struct! [

	get-version [function! [			"Get REBOL version."
		[cdecl]
		array		[tuple!]
	]]

	begin [function! [					"Set up REBOL interpreter."
		[cdecl]
		arguments	[options!]
		host		[handle!]
		return:		[integer!]
	]]
	start [function! [					"Start REBOL interpreter."
		[cdecl]
		program		[binary!]			"Compressed startup code, or NULL"
		size		[integer!]
		flags		[unsigned!]
		return:		[integer!]
	]]
	; Not implemented:
	reset [function! [					"Reset REBOL interpreter."
		[cdecl]
	]]
	extend [function! [					"Register embedded extension."
		[cdecl]
		interface	[c-string!]
		call		[integer!]			"call!"
		return:		[rebol!]
	]]
	escape [function! [					"Signal execution interruption."
		[cdecl]
		reserved	[integer!]			"0"
	]]

	do-string [function! [				"Execute text as REBOL program."
		[cdecl]
		text		[c-string!]
		flags		[unsigned!]			"0"
		result		[pointer! [value!]]
		return:		[type!]
	]]
	do-binary [function! [				"Execute binary REBOL program."
		[cdecl]
		program		[binary!]			"REBOL compressed text"
		size		[integer!]
		flags		[unsigned!]			"0"
		key			[unsigned!]
		result		[pointer! [value!]]
		return:		[type!]				"0: encoding error"
	]]
	; Not implemented:
	do [function! [						"Execute REBOL block."
		[cdecl]
		block		[series!]
		flags		[unsigned!]			"0"
		result		[pointer! [value!]]
		return:		[type!]				"0: encoding error"
	]]
	do-commands [function! [			"Execute REBOL extension commands."
		[cdecl]
		block		[series!]
		flags		[unsigned!]			"0"
		context		[context!]			"Or NULL"
	]]

	print [function! [					"Print formatted data to the console."
		[cdecl variadic]
		; format	[c-string!]
		;	value	[variant!]
		;	...
	]]
	print-last [function! [				"Print top REBOL stack value."
		[cdecl]
		flags		[unsigned!]			"0"
		marker		[c-string!]			"Console output line indicator"
	]]

	do-event [function! [				"Add an event."
		[cdecl]
		event		[event!]			"Copied"
		return:		[integer!]			"FALSE: queue full"
	]]

	make-block [function! [				"Return a new REBOL block."
		[cdecl]
		length		[unsigned32!]
		return:		[series!]
	]]
	make-string [function! [			"Return a new REBOL string."
		[cdecl]
		length		[unsigned32!]
		unicode?	[logic!]
		return:		[series!]
	]]
	make-image [function! [				"Return a new REBOL image."
		[cdecl]
		width		[unsigned32!]
		height		[unsigned32!]
		return:		[series!]			"NULL: too large"
	]]

	protect-recycle [function! [		"Prevent garbage collection."
		[cdecl]
		series		[series!]
		protect?	[logic!]
	]]

	get-string [function! [				"Get pointer into REBOL string."
		[cdecl]
		string		[series!]
		index		[unsigned32!]		"0 based"
		pointer		[binary-reference!]
		return:		[integer!]			"Length, > 0: Unicode, < 0: bytes"
	]]

	map-word [function! [				"Map word name to symbol ID."
		[cdecl]
		string		[c-string!]			"UTF-8"
		return:		[symbol!]
	]]
	map-words [function! [				"Convert word values in block to array of symbol ID's."
		[cdecl]
		block		[series!]
		return:		[symbol-array!]		"First is length"
	]]
	name-of [function! [				"Return word name for symbol ID."
		[cdecl]
		word		[symbol!]
		return:		[c-string!]			"UTF-8 copy"
	]]
	find-word [function! [				"Find index of symbol in array."
		[cdecl]
		words		[symbol-array!]		"First is length"
		word		[symbol!]
		return:		[unsigned32!]		"0: not found"
	]]

	get-series [function! [				"Get series properties."
		[cdecl]
		series		[series!]
		what		[property!]
		return:		[variant!]			"0: invalid property"
	]]

	pick-char [function! [				"Return a character from a REBOL string."
		[cdecl]
		string		[series!]
		index		[unsigned32!]		"0 based"
		return:		[integer!]			"Unicode, -1: out of range"
	]]
	poke-char [function! [				"Set a character in a REBOL string."
		[cdecl]
		string		[series!]
		index		[unsigned32!]		"0 based, out of range: append"
		char		[unsigned32!]		"Unicode"
		return:		[unsigned32!]		"Index"
	]]

	pick [function! [					"Get a value from a REBOL series."
		[cdecl]
		series		[series!]
		index		[unsigned32!]		"0 based"
		result		[pointer! [value!]]
		return:		[type!]				"0: out of range"
	]]
	poke [function! [					"Set a value in a REBOL series."
		[cdecl]
		series		[series!]
		index		[unsigned32!]		"0 based, out of range: append"
		value		[value!]
		type		[type!]
		return:		[integer!]			"TRUE: out of range and appended"
	]]

	words-of [function! [				"Return words local to object as array of symbol ID's."
		[cdecl]
		object		[series!]
		return:		[symbol-array!]		"First is length"
	]]
	get-in [function! [					"Get a field value from a REBOL object."
		[cdecl]
		object		[series!]
		word		[symbol!]
		result		[pointer! [value!]]
		return:		[type!]				"0: not found"
	]]
	set-in [function! [					"Set a field value in a REBOL object."
		[cdecl]
		object		[series!]
		word		[symbol!]
		value		[value!]
		type		[type!]
		return:		[type!]				"0: not found or protected"
	]]

	do-callback [function! [			"Execute REBOL callback."
		[cdecl]
		callback	[callback!]
		return:		[variant!]			"Sync: result type; async: TRUE: queued"
	]]

]
