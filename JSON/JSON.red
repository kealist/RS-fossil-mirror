Red [
	Title:		"JSON"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2013,2014 Kaj de Vos. All rights reserved."
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
		Red > 0.4.1
		%C-library/ANSI.red
		READ
	}
	Purpose: {
		To convert Red values to and from JSON format.
	}
	Notes: {
		Needs to be compiled. Current Red interpreter can't LOAD the script.
		Floats are loaded as file! for now because Red doesn't have them yet.
		Escaped UTF-16 surrogate pairs not supported yet.
		Red words to convert to JSON should not contain illegal characters.
	}
	Tabs:		4
]


#include %../C-library/ANSI.red


character: charset [not {"\} #"^(null)" - #"^(1F)"]
escapes: charset {"\/}


sign: charset "+-"
exponent-prefix: charset "Ee"
exponent: [exponent-prefix  opt sign  some digit]

escape: [#"\" [
	set char escapes
	| #"n" (char: lf)
	| #"r" (char: cr)
	| #"t" (char: tab)
	| #"f" (char: #"^(page)")
	| #"b" (char: #"^(back)")
	| #"u" start: 4 skip
		(char: make char! any [
			load-hex append/part clear _string  start 4
			0
		])
	]
]

load-JSON: func [					"Return value(s) converted from JSON format."
	value			[string! file!]	"JSON value"
	/objects						"Convert objects to Red objects."
	/keys							"Convert object keys to Red value."
	/values							"Convert string values to Red value."
	/into							"Insert contents of a JSON array or object into existing block."
		out			[block!]		"Result buffer"
	/local  ; FIXME: #600
;		start stop
		escaped string loaded element pair object array
][
	escaped: [
;		collect into value [any [  ; FIXME: #598
;			keep some character
;			| escape keep (char)
;		]]
;		(value: head value)
		any [
			start: some character stop:
				(append/part value start  offset? start stop)  ; FIXME: #580
			| escape (append value char)
		]
		#"^""
	]
	string: [
		set value character #"^""
		| escape #"^"" (value: char)
		| (value: make string! 0) escaped
	]
	loaded: [
		(value: clear _string) escaped
		(value: load/into value  clear _item)
	]
	element: [
		any blank [
			#"^"" [if (values) then loaded | string]
			| start: [opt #"-" [#"0" | non-zero  any digit]] [
				[#"." some digit  opt exponent | exponent] stop:	; Float
					(value: append/part make file! 0				; TODO: conversion
						start  offset? start stop
					)
				| stop:												; Integer
					if (integer? value: load/into append/part
						clear _string  start  offset? start stop
						clear _item
					)
				]
			| "true"	(value: yes)
			| "false"	(value: no)
			| "null"	(value: none)
			| #"[" collect set value [array]
			| #"{" collect set value [object]
				(if objects [value: context value])  ; TODO: #618
		]
		any blank
	]
	pair: [
		any blank  #"^"" [											; Key
			if (objects) then [
				(value: clear _string) escaped

				if (set-word? value: load/into
					append value #":"
					clear _item
				)
			]|[
				if (keys) then loaded
				| string
			]
		]
		any blank  #":"
		keep (value)

		element keep (value)
	]
	object: [
		any blank
		opt [pair  any [#"," pair]]
		#"}"
	]
	array: [
		any blank
		opt [
			element keep (value)
			any [#"," element keep (value)]
		]
		#"]"
	]

	if any [string? value  value: read value] [
		either out [
			if parse/case value  either objects [
				[collect into out [any blank  #"[" array  any blank]]
			][
				[collect into out [any blank [#"{" object | #"[" array] any blank]]
			][
				out
			]
		][
			if parse/case value [element] [value]
		]
	]
]

encode-JSON: function [				"Return string with control characters escaped to JSON format."
	string			[string!]		"String to encode (changed, returned)"
	return:			[string!]
][
	parse string [any [
		some character
		| ahead escapes  insert #"\"  skip
		| remove #"^(line)"	insert "\n"
		| remove #"^M"		insert "\r"
		| remove #"^(tab)"	insert "\t"
		| remove #"^(page)"	insert "\f"
		| remove #"^(back)"	insert "\b"
		; TODO: optimise memory:
		| remove set char skip  insert "\u" insert (any [to-hex/size char 4  "0000"])
	]]
	string
]

to-JSON: function [					"Return value converted to JSON format."
	value							"Type is lost for some datatypes."
	/flat							"Omit spacing."
	/indent							"Indent level for series"
		margin		[integer!]		"Number of tabs"
	/map							"Convert even sized any-block! to a JSON object."
	/deep							"Convert nested any-block! to JSON objects."
	/into							"Insert result into existing string."
		result		[string!]		"Result buffer"
	return:			[string! none!]	"NONE: error"
][
	unless indent [margin: 0]

	clear _string

	out: either result [
		either tail? result [result] [_string]
	][
		make string! 0
	]
	case [
		find [integer! logic!] type: type?/word value
			append out value
		any-word? value
			append append append out  #"^"" value #"^""
		find [none! unset!] type
			append out "null"
		any-block? value [
			margin: margin + 1

			either all [map  even? length? value] [  ; Object
				append out #"{"

				unless empty? value [
					either flat [
						foreach [item value] value [
							append encode-JSON append  tail append out  #"^"" item {":}

							unless either deep [
								to-JSON/flat/map/deep/into value  tail out
							][
								to-JSON/flat/into value  tail out
							][
								return none
							]
							append out #","
						]
						clear back tail out
					][
						append out newline

						foreach [item value] value [
							append encode-JSON append  tail append append/dup out
								tab margin  #"^"" item {": }

							unless either deep [
								to-JSON/indent/map/deep/into value margin  tail out
							][
								to-JSON/indent/into value margin  tail out
							][
								return none
							]
							append out ",^(line)"
						]
						append/dup remove back back tail out  tab  margin - 1
					]
				]
				append out #"}"
			][	; Array
				append out #"["

				unless empty? value [
					either flat [
						foreach value value [
							unless either deep [
								to-JSON/flat/map/deep/into value  tail out
							][
								to-JSON/flat/into value  tail out
							][
								return none
							]
							append out #","
						]
						clear back tail out
					][
						append out newline

						foreach value value [
							append/dup out  tab margin

							unless either deep [
								to-JSON/indent/map/deep/into value margin  tail out
							][
								to-JSON/indent/into value margin  tail out
							][
								return none
							]
							append out ",^(line)"
						]
						append/dup remove back back tail out  tab  margin - 1
					]
				]
				append out #"]"
			]
		]
		object? value [
			append out #"{"

			unless empty? names: words-of value [  ; TODO: #614
				either flat [
					foreach item names [  ; TODO: #617
						append append append out  #"^"" item {":}

						unless either deep [
							to-JSON/flat/map/deep/into do [value/:item]  tail out
						][
							to-JSON/flat/into do [value/:item]  tail out
						][
							return none
						]
						append out #","
					]
					clear back tail out
				][
					append out newline
					margin: margin + 1

					foreach item names [
						append append append append/dup out  tab margin  #"^"" item {": }

						unless either deep [
							to-JSON/indent/map/deep/into do [value/:item] margin  tail out
						][
							to-JSON/indent/into do [value/:item] margin  tail out
						][
							return none
						]
						append out ",^(line)"
					]
					append/dup remove back back tail out  tab  margin - 1
				]
			]
			append out #"}"
		]
		all [bitset? value  not find/match append out value  "make bitset! [not "] [  ; TODO: #622
			append clear out  #"["

;			unless empty? value [  ; FIXME: #613, #614
				size: length? value

				either flat [
					either size <= 0100h [  ; Bytes
						repeat item size [
							if value/(item - 1) [
								append encode-JSON append  tail append out
									#"^""  make char! item - 1  {",}
							]
						]
					][	; Integers
						repeat item size [
							if value/(item - 1) [
								append append out  item - 1  #","
							]
						]
					]
					clear back tail out  ; FIXME: #613, #614
				][
					append out newline
					margin: margin + 1

					either size <= 0100h [  ; Bytes
						repeat item size [
							if value/(item - 1) [
								append encode-JSON append  tail append append/dup out
									tab margin  #"^""  make char! item - 1  {",^(line)}
							]
						]
					][	; Integers
						repeat item size [
							if value/(item - 1) [
								append append append/dup out
									tab margin  item - 1  ",^(line)"
							]
						]
					]
					append/dup remove back back tail out  tab  margin - 1  ; FIXME: #613, #614
				]
;			]
			append out #"]"
		]
		yes
			append encode-JSON append insert  clear out  #"^"" value #"^""
	]
	either into [
		either empty? _string [
			tail result
		][
			out: insert result _string
			clear _string
			out
		]
	][
		head out
	]
]
