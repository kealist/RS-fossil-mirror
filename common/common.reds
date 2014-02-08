Red/System [
	Title:		"Common Definitions"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011,2012 Kaj de Vos. All rights reserved."
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
	Tabs:		4
]


#define integer32!				integer!

; FIXME:
#define unsigned32!				integer!
#define integer16!				integer!
#define unsigned16!				integer!
#define integer64!				float!

integer16-reference!: alias struct! [
	low							[byte!]  ; FIXME: reversed for big-endian
	high						[byte!]
]
integer64-reference!: alias struct! [
	low							[unsigned32!]  ; FIXME: reversed for big-endian
	high						[integer32!]
]

#define variant!				integer!
#define opaque!					[struct! [dummy [variant!]]]
handle!:						alias opaque!
#define as-handle				[as handle! ]
#define binary!					[pointer! [byte!]]
#define as-binary				[as binary! ]

handle-reference!:				alias struct! [value [handle!]]
binary-reference!:				alias struct! [value [binary!]]
string-reference!:				alias struct! [value [c-string!]]


#define none?					[null = ]

#define free-any				[free as-binary ]


; C types

#define unsigned!				integer!
#define long!					integer!
#define unsigned-long!			integer!
#define enum!					integer!
#define double!					float!

#define size!					integer!
file!:							alias opaque!

argument-list!:					alias struct! [item [integer!]]


; Limits for GNU (Syllable, Linux)
; TODO: check for other systems

; 32 bits
#define min-long				-2147483648  ; LONG_MIN
#define max-long				7FFFFFFFh  ; 2147483647, LONG_MAX
#define max-unsigned-long		FFFFFFFFh  ; 4294967295, ULONG_MAX

; 64 bits
;#define min-long				-9223372036854775808  ; LONG_MIN
;#define max-long				9223372036854775807  ; 7FFFFFFFFFFFFFFFh, LONG_MAX
;#define max-unsigned-long		18446744073709551615  ; FFFFFFFFFFFFFFFFh, ULONG_MAX
