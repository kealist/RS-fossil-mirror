Red [
	Title:		"Tagged NetStrings"
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
		Red >= 0.4.3
		%common/common.red
		READ
	}
	Purpose: {
		To convert Red values to and from (Tagged) NetStrings format.
	}
	Notes: {
		TNetStrings specification: http://tnetstrings.org
		String!s and file!s other than Latin-1 yield size value incompatible with
		specification.
	}
	Tabs:		4
]


#include %../common/common.red


load-TNetString: function [			"Return value(s) converted from (Tagged) NetStrings format."
	value			[string! file!]	"TNetStrings value(s)"
	/objects						"Convert dictionaries to Red objects."
	/keys							"Convert dictionary keys to Red value."
	/values							"Convert binary values to Red value."
	/all							"Always return a block."
	/into							"Insert result into existing block."
		out			[block!]		"Result buffer (changed)"
][
	header: [
		start: 1 9 digit stop: #":"
		(size: load/part/into start stop  clear _item)
	]
	binary: [
		ahead [size skip #","]
		[if (value)
			start: size skip
			keep (load/part/into start size  clear _item)
		| if (zero? size) keep (make string! 0)  ; FIXME: #603
		| keep size skip
		]
		skip
	]
	element: [
		"0:~"			keep (none)												; null
		| "4:true!"		keep (yes)
		| "5:false!"	keep (no)
		| [header [
			(value: values) binary
			; WARN: LOAD rules allow spaces
			| start: size skip #"#"

				if (integer? value: load/part/into start size  clear _item)
					keep (value)
			; FIXME: check end positions
			| ahead [size skip #"^^"]
				start: opt #"-"  any digit  opt [#"." any digit] #"^^"

				if (any [
					float? value: load/part/into start size  clear _item
					integer? value
				])
					keep (value)
			| ahead [size skip #"]"] collect [any element] #"]"					; List
			| ahead [size skip #"}"]											; Dictionary
				[if (objects) then [
					collect set value [any [
						header  start: size skip #","							; Key

						if (set-word? value: load/into append append/part
							clear _string  start size  #":"
							clear _item
						)
							keep (value)

						element
					]]
					keep (context value)
				]|
					collect [any [
						header  (value: keys) binary							; Key
						element
					]]
				]
				#"}"
			]
		]
	]

	if any [string? value  value: read value] [
		either out [
			here: out

			if parse/case value [collect after out [any element]] [
				either any [all  1 <> offset? here out] [out] [here/1]
			]
		][
			if parse/case value [collect set out [any element]] [
				either any [all  not single? out] [out] [out/1]
			]
		]
	]
]

to-TNetString: function [			"Return value converted to (Tagged) NetString."
	value							"Type is lost for some datatypes."
	/map							"Convert even sized any-block! to a TNetStrings dictionary."
	/deep							"Convert nested any-block! to TNetStrings dictionaries."
	/only							"Omit outer envelope from a TNetStrings list."
	/into							"Insert result into existing string. Appending uses result buffer directly."
		result		[string!]		"Result buffer (changed, returned)"
	return:			[string! none!]	"NONE: error"
][
	clear _string

	out: either result [
		either tail? result [result] [_string]
	][
		make string! 0
	]
	switch/default type: type?/word value [
		integer! [
			append insert out
				length? append insert out  #":" value
				#"#"
		]
		logic! [
			append insert out
				length? append insert out  #":" value
				#"!"
		]
		; FIXME: only Latin-1 yields proper size
		char! [append append append out  "1:" value #","]
		object! [
			append out #":"

			foreach name  words-of value [
				append insert  tail out
					length? append  tail append out #":"  name
					#","

				unless either deep [
					to-TNetString/map/deep/into get in value name  tail out
				][
					to-TNetString/into get in value name  tail out
				][
					return none
				]
			]
			; FIXME: only Latin-1 yields proper size
			if 999'999'999 < size: (length? out) - 1 [return none]

			append insert out  size #"}"
		]
	][
		case [
			any-string? value [
				; FIXME: only Latin-1 yields proper size
				if 999'999'999 < size: length? value [return none]

				append append append append out  size #":" value #","
			]
			any-word? value
				append insert out
					length? append insert out  #":" value
					#","
			find [none! unset!] type
				append out "0:~"
			any-block? value
				either all [map  even? length? value] [  ; Dictionary
					append out #":"

					foreach [name value] value [
						either any-string? name [
							; FIXME: only Latin-1 yields proper size
							if 999'999'999 < size: length? name [return none]

							append append append append out  size #":" name #","
						][
							append insert  tail out
								length? append  tail append out #":"  name
								#","
						]
						unless either deep [
							to-TNetString/map/deep/into value  tail out
						][
							to-TNetString/into value  tail out
						][
							return none
						]
					]
					; FIXME: only Latin-1 yields proper size
					if 999'999'999 < size: (length? out) - 1 [return none]

					append insert out  size #"}"
				][	; List
					foreach value value [
						unless either deep [
							to-TNetString/map/deep/into value  tail out
						][
							to-TNetString/into value  tail out
						][
							return none
						]
					]
					unless only [
						; FIXME: only Latin-1 yields proper size
						if 999'999'999 < size: length? out [return none]

						; TODO: insert in one go
						insert out #":"
						append insert out  size #"]"
					]
				]
			all [bitset? value  not complement? value] [
				either 0100h >= size: length? value [  ; Bytes
					repeat item size [
						if value/(item - 1) [
							append append append out  "1:"  make char! item - 1  #","
						]
					]
				][	; Integers
					repeat item size [
						if value/(item - 1) [
							append insert tail out
								length? append insert  tail out  #":"  item - 1
								#"#"
						]
					]
				]
				unless only [
					; FIXME: only Latin-1 yields proper size
					if 999'999'999 < size: length? out [return none]

					; TODO: insert in one go
					insert out #":"
					append insert out  size #"]"
				]
			]
			yes [
				; FIXME: only Latin-1 yields proper size
				if 999'999'999 < size: length? append insert  clear out  #":" value [
					return none
				]
				append insert out  size #","
			]
		]
	]
	either into [
		either empty? _string [  ; Append mode
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
