Red [
	Title:		"Local file Input/Output"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2013 Kaj de Vos. All rights reserved."
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
		%common/common.red
	}
	Tabs:		4
]


#include %../common/common.red


read: routine ["Read file."
	name			[string!]  ; [file! url!]
;	return:			[string! none!]
	/local file data
][
	file: to-local-file name

	data: read-file either zero? compare-string-part file "file:" 5 [
		file + 5
	][
		file
	]
	free-any file

	either none? data [
		RETURN_NONE
	][
		SET_RETURN ((string/load data  (length? data) + 1))
;		free data
	]
]

write: routine ["Write file."
	name			[string!]  ; [file! url!]
	data			[string!]
	return:			[logic!]
	/local file out ok?
][
	file: to-local-file name
	out: to-UTF8 data

	ok?: write-file either zero? compare-string-part file "file:" 5 [
		file + 5
	][
		file
	] out

	free-any out
	free-any file
	ok?
]


load*: :load

load: function ["Return a value or block of values by loading a source."
	source			[string! file!]
	/all							"Always return a block."
	/into							"Insert result into existing block."
		out			[block!]		"Result buffer"
][
	if file? source [source: read source]

	either source [
		either all [
			either into [
				do [load*/all/into source out]
			][
				do [load*/all source]
			]
		][
			either into [
				do [load*/into source out]
			][
				do [load* source]
			]
		]
	][
		none
	]
]

do*: :do
_result: make block! 1  ; WARN: not thread safe

do: function ["Execute code from a source."
	source
][
	if file? source [source: read source]

	first head reduce/into dummy: [do* source] clear _result  ; Force use of interpreter
]
