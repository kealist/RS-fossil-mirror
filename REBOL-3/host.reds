Red/System [
	Title:		"REBOL 3 Interpreter Library"
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
		Red/System >= 0.3.2
		%common/common.reds
		%REBOL-3/common.reds
	}
	Tabs:		4
]


#include %../common/common.reds

rebol: context [

	#include %common.reds


	#switch OS [
		Windows		[#define R3-library "r3lib.dll"]
		MacOSX		[#define R3-library "libr3.so.2.5"]
		#default	[#define R3-library "libr3.so"]
	]
	#import [R3-library cdecl [

		get-version: "RL_Version" [			"Get REBOL version."
			array		[tuple!]
		]

		begin: "RL_Init" [					"Set up REBOL interpreter."
			arguments	[options!]
			host		[handle!]
			return:		[integer!]
		]
		start: "RL_Start" [					"Start REBOL interpreter."
			program		[binary!]			"Compressed startup code, or NULL"
			size		[integer!]
			flags		[unsigned!]
			return:		[integer!]
		]
		; Not implemented:
		;reset: "RL_Reset" [					"Reset REBOL interpreter."
		;]
		extend: "RL_Extend" [				"Register embedded extension."
			interface	[c-string!]
			call		[call!]
			return:		[rebol!]
		]
		escape: "RL_Escape" [				"Signal execution interruption."
			reserved	[integer!]			"0"
		]

		do-string: "RL_Do_String" [			"Execute text as REBOL program."
			text		[c-string!]
			flags		[unsigned!]			"0"
			result		[pointer! [value!]]
			return:		[type!]
		]
		do-binary: "RL_Do_Binary" [			"Execute binary REBOL program."
			program		[binary!]			"REBOL compressed text"
			size		[integer!]
			flags		[unsigned!]			"0"
			key			[unsigned!]
			result		[pointer! [value!]]
			return:		[type!]				"0: encoding error"
		]
		; Not implemented:
		;do: "RL_Do_Block" [					"Execute REBOL block."
		;	block		[series!]
		;	flags		[unsigned!]			"0"
		;	result		[pointer! [value!]]
		;	return:		[type!]				"0: encoding error"
		;]
		do-commands: "RL_Do_Commands" [		"Execute REBOL extension commands."
			block		[series!]
			flags		[unsigned!]			"0"
			context		[context!]			"Or NULL"
		]

		print-form: "RL_Print" [			"Print formatted data to the console."
			[variadic]
			; format	[c-string!]
			;	value	[variant!]
			;	...
		]
		print-last: "RL_Print_TOS" [		"Print top REBOL stack value."
			flags		[unsigned!]			"0"
			marker		[c-string!]			"Console output line indicator"
		]

		do-event: "RL_Event" [				"Add an event."
			event		[event!]			"Copied"
			return:		[integer!]			"FALSE: queue full"
		]

		make-block: "RL_Make_Block" [		"Return a new REBOL block."
			length		[unsigned32!]
			return:		[series!]
		]
		make-string: "RL_Make_String" [		"Return a new REBOL string."
			length		[unsigned32!]
			unicode?	[logic!]
			return:		[series!]
		]
		make-image: "RL_Make_Image" [		"Return a new REBOL image."
			width		[unsigned32!]
			height		[unsigned32!]
			return:		[series!]			"NULL: too large"
		]

		protect-recycle: "RL_Protect_GC" [	"Prevent garbage collection."
			series		[series!]
			protect?	[logic!]
		]

		get-string: "RL_Get_String" [		"Get pointer into REBOL string."
			string		[series!]
			index		[unsigned32!]		"0 based"
			pointer		[binary-reference!]
			return:		[integer!]			"Length, > 0: Unicode, < 0: bytes"
		]

		map-word: "RL_Map_Word" [			"Map word name to symbol ID."
			string		[c-string!]			"UTF-8"
			return:		[symbol!]
		]
		map-words: "RL_Map_Words" [			"Convert word values in block to array of symbol ID's."
			block		[series!]
			return:		[symbol-array!]		"First is length"
		]
		name-of: "RL_Word_String" [			"Return word name for symbol ID."
			word		[symbol!]
			return:		[c-string!]			"UTF-8 copy"
		]
		find-word: "RL_Find_Word" [			"Find index of symbol in array."
			words		[symbol-array!]		"First is length"
			word		[symbol!]
			return:		[unsigned32!]		"0: not found"
		]

		get-series: "RL_Series" [			"Get series properties."
			series		[series!]
			what		[property!]
			return:		[variant!]			"0: invalid property"
		]

		pick-char: "RL_Get_Char" [			"Return a character from a REBOL string."
			string		[series!]
			index		[unsigned32!]		"0 based"
			return:		[integer!]			"Unicode, -1: out of range"
		]
		poke-char: "RL_Set_Char" [			"Set a character in a REBOL string."
			string		[series!]
			index		[unsigned32!]		"0 based, out of range: append"
			char		[unsigned32!]		"Unicode"
			return:		[unsigned32!]		"Index"
		]

		pick: "RL_Get_Value" [				"Get a value from a REBOL series."
			series		[series!]
			index		[unsigned32!]		"0 based"
			result		[pointer! [value!]]
			return:		[type!]				"0: out of range"
		]
		poke: "RL_Set_Value" [				"Set a value in a REBOL series."
			series		[series!]
			index		[unsigned32!]		"0 based, out of range: append"
			value		[value!]
			type		[type!]
			return:		[integer!]			"TRUE: out of range and appended"
		]

		words-of: "RL_Words_Of_Object" [	"Return words local to object as array of symbol ID's."
			object		[series!]
			return:		[symbol-array!]		"First is length"
		]
		get-in: "RL_Get_Field" [			"Get a field value from a REBOL object."
			object		[series!]
			word		[symbol!]
			result		[pointer! [value!]]
			return:		[type!]				"0: not found"
		]
		set-in: "RL_Set_Field" [			"Set a field value in a REBOL object."
			object		[series!]
			word		[symbol!]
			value		[value!]
			type		[type!]
			return:		[type!]				"0: not found or protected"
		]

		callback: "RL_Callback" [			"Execute REBOL callback."
			callback	[callback!]
			return:		[variant!]			"Sync: result type; async: TRUE: queued"
		]

	]]
]
