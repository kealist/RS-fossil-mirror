Red [
	Title:		"Red Console"
	Author:		["Nenad Rakocevic" "Kaj de Vos"]
	Rights:		"Copyright (c) 2012-2014 Nenad Rakocevic. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
	}
	Needs: {
		Red >= 0.5
		%C-library/input-output.red | %common/input-output.red
		%Red/environment/console/help.red
		%Red/system/library/call/call.red
	}
	Tabs:		4
]


#system-global [
	#switch OS [
		Android []
		Windows [
			#import [
				"kernel32.dll" stdcall [
					SetConsoleTitle: "SetConsoleTitleA" [
						title			[c-string!]
						return:			[integer!]
					]
				]
			]
		]
		#default [
			#either OS = 'MacOSX [
				#define ReadLine-library "libreadline.dylib"
			][
				#define ReadLine-library "libreadline.so.6"
				#define History-library "libhistory.so.6"
			]
			#import [
				ReadLine-library cdecl [
					read-console: "readline" [			"Read a line from the console."
						prompt			[c-string!]
						return:			[c-string!]
					]
					rl-bind-key: "rl_bind_key" [
						key				[integer!]
						command			[integer!]
						return:			[integer!]
					]
					_rl-insert: "rl_insert" [
						count			[integer!]
						key				[integer!]
						return:			[integer!]
					]
				]
				#if OS <> 'MacOSX [
					History-library cdecl [
						add-history: "add_history" [	"Add line to the history."
							line		[c-string!]
						]
					]
				]
			]

			rl-insert: function [
				[cdecl]
				count		[integer!]
				key			[integer!]
				return:		[integer!]
			][
				_rl-insert count key
			]
		]
	]
]

begin-console: routine [
	title		[string!]
][
	#switch OS [
		Android []
		Windows [
			if zero? SetConsoleTitle as-c-string string/rs-head title [
				print-line "SetConsoleTitle failed."
			]
		]
		#default [
			rl-bind-key as-integer tab  as-integer :rl-insert
		]
	]
]

input-line: routine [
	prompt		[string!]
;	return:		[string! none!]
	/local		line
][
	#switch OS [
		Android [
			line: ask as-c-string string/rs-head prompt

			either none? line [  ; EOF or error
				RETURN_NONE
			][
				SET_RETURN ((string/load line  (length? line) + 1  UTF-8))
;				free-any line
			]
		]
		Windows [
			line: ask as-c-string string/rs-head prompt

			either none? line [  ; EOF or error
				RETURN_NONE
			][
				SET_RETURN ((string/load line  (length? line) + 1  UTF-8))
;				free-any line
			]
		]
		#default [
			line: read-console as-c-string string/rs-head prompt

			either none? line [  ; EOF
				RETURN_NONE
			][
				#if OS <> 'MacOSX [add-history line]

				SET_RETURN ((string/load line  (length? line) + 1  UTF-8))
;				free-any line
			]
		]
	]
]

do-input: function [
	script		[string!]
][
	unless unset? set/any 'result do script [
		if 69 = length? result: mold/part :result 69 [
			; Truncate for display width 72
;			FIXME?: tabs & newlines
			clear at result 66
			append result "..."
		]
		print ["==" result]
	]
]

halt?: yes

halt: does [
	halt?: yes
	()
]

do-console: function [] [
	result: none
	all [
		file: take-argument
		(
			set 'halt? no
			script: read file
		)
		not unset? set/any 'result do script
		halt?
		print ["==" mold :result]
	]

	if halt? [
		begin-console "Red Console"

		print {
-=== Red Console alpha version ===-
Type HELP for starter information.
}

		buffer: make string! 1000
		escape?: literal?: no  ; string! or char!
		strings: blocks: parens: 0

		while [
			line: input-line case [
				strings > 0	"{^-"
				parens > 0	"(^-"
				blocks > 0	"[^-"
				yes			"red>> "
			]
		][
			forall line [
				escape?: either all [line/1 = #"^^"  not escape?  any [literal?  not zero? strings]] [
					yes
				][
					switch line/1 [
						#"^"" [if all [not escape?  zero? strings]						[literal?: not literal?]]
						#"{"  [unless any [literal? escape?]							[strings: strings + 1]]
						#"}"  [unless any [literal?  zero? strings  escape?]			[strings: strings - 1]]
						#";"  [if all [zero? strings  not literal?]						[clear line]]  ; Comment
						#"["  [if all [zero? strings  not literal?]						[blocks: blocks + 1]]
						#"]"  [unless any [literal?  not zero? strings  zero? blocks]	[blocks: blocks - 1]]
						#"("  [if all [zero? strings  not literal?]						[parens: parens + 1]]
						#")"  [unless any [literal?  not zero? strings  zero? parens]	[parens: parens - 1]]
					]
					no
				]
			]
			append  append buffer line  newline

			if all [zero? blocks  zero? parens  zero? strings] [
				do-input buffer
				clear buffer
				literal?: no
			]
		]
		unless empty? buffer [  ; Invalid rest
			do-input buffer
		]
	]
]

#include %../../Red/environment/console/help.red

; Disable ansi.reds inclusion in there:
#include %../../Red/system/library/call/call.red

about: does [
	print [
		"Red" system/version newline
		"Platform:" system/platform {

Copyright (c) 2011-2014 Nenad Rakocevic and contributors. All rights reserved.
Licensed under the Boost Software License, Version 1.0.
Copyright (c) 2011-2014 Kaj de Vos. All rights reserved.
Licensed under the BSD license.

Use LICENSE for full license text.
}
	]
]
license: does [
	print
{Copyright (c) 2011-2014 Nenad Rakocevic and contributors. All rights reserved.
Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.


Copyright (c) 2011-2014 Kaj de Vos. All rights reserved.

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
]

q: :quit

do-console
