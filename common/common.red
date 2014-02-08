Red [
	Title:		"Common Definitions"
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
		Red >= 0.4.1
		%C-library/ANSI.reds
	}
	Notes: {
		Needs to be compiled. Current Red interpreter can't properly LOAD the script.
	}
	Tabs:		4
]


#system-global [#include %../C-library/ANSI.reds]


; Buffer working space

; WARN: not thread safe
_string: make string! 0
_block: make block! 0
_item: make block! 1


; Program arguments

get-args-count: routine ["Return number of program arguments, excluding program name."
	return:			[integer!]
][
	system/words/get-args-count
]
take-argument: routine ["Consume and return next program argument."
;	return:			[string! none!]  "Argument, or NONE"
	/local			argument
][
	argument: system/words/take-argument

	either none? argument [
		RETURN_NONE
	][
		SET_RETURN ((string/load argument  (length? argument) + 1))
;		end-argument argument
	]
]
get-argument: routine ["Return a program argument."
	offset			[integer!]  "0: program file name"
;	return:			[string! none!]  "Argument, or NONE"
	/local			argument
][
	argument: system/words/get-argument offset

	either none? argument [
		RETURN_NONE
	][
		SET_RETURN ((string/load argument  (length? argument) + 1))
;		end-argument argument
	]
]
get-arguments: function ["Return program arguments, excluding program name."
	return:			[block! none!]
][
	all [
		0 < count: get-args-count
		(
			list: make block! count

			repeat i count [
				append list  get-argument i
			]
			list
		)
	]
]


; PARSE rules

blank:			charset " ^(tab)^(line)^M^(page)"

letter:			charset [#"A" - #"Z"  #"a" - #"z"]

digit:			charset "0123456789"
non-zero:		charset "123456789"
octal:			charset "01234567"
hexadecimal:	union digit charset [#"A" - #"F"  #"a" - #"f"]


; Common functions

Windows?: system/platform = 'Windows

found?: func ["Test if value is not NONE."
	value
	return:			[logic!]
][
	not none? :value
]

any-word!: [word! lit-word! set-word! get-word! issue! refinement! datatype!]
any-string!: [string! file!]
any-block!: [block! paren! path! lit-path! set-path! get-path!]

any-word?: func ["Test if value is a word of any type."
	value
	return:			[logic!]
][
	found? find any-word! type?/word :value
]
series?: func ["Test if value is a series of any type."
	value
	return:			[logic!]
][
	found? any-series? :value
]
any-string?: func ["Test if value is a string of any type."
	value
	return:			[logic!]
][
	found? find any-string! type?/word :value
]
any-block?: func ["Test if value is a block of any type."
	value
	return:			[logic!]
][
	found? find any-block! type?/word :value
]

single?: func ["Test if series has just one element."
	series			[series!]
	return:			[logic!]
][
	1 = length? series
]

offset?: func ["Return difference between two positions in a series."
	series1			[series!]
	series2			[series!]
	return:			[integer!]
][
	subtract index? series2  index? series1
]


; Unicode

#system [

	Latin1-to-UTF8: function ["Return UTF-8 encoding of Latin-1 text."
		series			[red-string!]
		return:			[c-string!]
		/local
			text tail char
			out index
	][
		text: string/rs-head series
		tail: string/rs-tail series

		out: allocate (as-integer tail - text) * 2 + 1
		if none? out [return null]
		index: out

		while [
			char: text/value  ; FIXME: tail overflow
			all [text < tail  char <> as-byte 0]
		][
			either char < as-byte 80h [
				index/1: char
				index: index + 1
			][
				index/2: char and (as-byte 3Fh) or as-byte 80h
				index/1: char >>> 6 or as-byte C0h
				index: index + 2
			]
			text: text + 1
		]
		index/1: null-byte
		as-c-string resize out  (as-integer index - out) + 1
	]

	UCS2-to-UTF8: function ["Return UTF-8 encoding of UCS-2 Unicode text."
		series			[red-string!]
		return:			[c-string!]
		/local
			text tail char
			pointer
			out index
	][
		text: string/rs-head series
		tail: string/rs-tail series

		out: allocate (as-integer tail - text) / 2 * 3 + 1 + 3  ; Safety padding
		if none? out [return null]
		index: out

		while [
			pointer: as pointer! [integer!] text
			char: pointer/value and FFFFh  ; FIXME: tail overflow
			all [text < tail  char <> 0]
		][
			case [  ; Basic Multilingual Plane
				char < 80h [
					index/1: as-byte char
					index: index + 1
				]
				char < 0800h [
					index/2: as-byte char and 3Fh or 80h
					index/1: as-byte char >>> 6 or C0h
					index: index + 2
				]
				yes [
					pointer: as pointer! [integer!] index
					pointer/value:
						char << 16 and 3F0000h
						or (char << 2 and 3F00h)
						or (char >>> 12)
						or 008080E0h
					index: index + 3
				]
			]
			text: text + 2
		]
		index/1: null-byte
		as-c-string resize out  (as-integer index - out) + 1
	]

	UCS4-to-UTF8: function ["Return UTF-8 encoding of UCS-4 Unicode text."
		series			[red-string!]
		return:			[c-string!]
		/local
			text tail char
			out index pointer
	][
		text: as pointer! [integer!] string/rs-head series
		tail: string/rs-tail series

		out: allocate (as-integer tail - text) + 1 + 3  ; Safety padding
		if none? out [return null]
		index: out

		while [
			char: text/value  ; FIXME: tail overflow
			all [text < tail  char <> 0]
		][
			case [
				char < 80h [
					index/1: as-byte char
					index: index + 1
				]
				char < 0800h [
					index/2: as-byte char and 3Fh or 80h
					index/1: as-byte char >>> 6 or C0h
					index: index + 2
				]
				char <= FFFFh [
					pointer: as pointer! [integer!] index
					pointer/value:
						char << 16 and 3F0000h
						or (char << 2 and 3F00h)
						or (char >>> 12)
						or 008080E0h
					index: index + 3
				]
				char < 00200000h [  ; Above BMP
					pointer: as pointer! [integer!] index
					pointer/value:
						char << 24 and 3F000000h
						or (char << 10 and 3F0000h)
						or (char >>> 4 and 3F00h)
						or (char >>> 18)
						or 808080F0h
					index: index + 4
				]
				yes [
					print-line "Error in UCS4-to-UTF8: codepoint above 1FFFFFh"
				]
			]
			text: text + 1
		]
		index/1: null-byte
		as-c-string resize out  (as-integer index - out) + 1
	]

	to-UTF8: function ["Return UTF-8 encoding of a Red string."
		text			[red-string!]
		return:			[c-string!]
		/local			series
	][
		series: GET_BUFFER (text)

		switch GET_UNIT (series) [
			Latin1	[Latin1-to-UTF8 text]
			UCS-2	[UCS2-to-UTF8 text]
			UCS-4	[UCS4-to-UTF8 text]
			default	[
				print-line ["Error: unknown text encoding: " GET_UNIT (series)]
				null
			]
		]
	]

	to-local-file: function ["Return file name encoding for local system."
		name			[red-string!]
		return:			[c-string!]
		/local series head size out
	][
		#switch OS [
			Windows [
				series: GET_BUFFER (name)

				unless Latin1 = GET_UNIT (series) [
					print-line ["Error: invalid file name encoding: " GET_UNIT (series)]
					return null
				]

				head: string/rs-head name
				size: as-integer (string/rs-tail name) - head + 1  ; Closing null seems to be at tail

;				if zero? size [return null]

				out: allocate size

				if as-logic out [
					copy-part head out size
					out/size: null-byte  ; For safety
				]
				as-c-string out
			]
			#default [
				to-UTF8 name
			]
		]
	]

]
