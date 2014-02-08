Red/System [
	Title:		"GLib Binding"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2013 Kaj de Vos. All rights reserved."
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
		GLib
		%FPU-configuration.reds
	}
	Tabs:		4
]


#include %../common/FPU-configuration.reds


#define g-size!					unsigned-long!  ; size!
#define g-type!					g-size!
#define g-logic!				integer!
#define g-symbol!				unsigned32!  ; GQuark


g: context [

	g-list!: alias struct! [
		data						[handle!]
		next						[g-list!]
		back						[g-list!]
	]
	#define g-callback!				[function! []]

	g-error!: alias struct! [
		domain						[g-symbol!]
		code						[integer!]
		message						[c-string!]
	]
	g-error-reference!:				alias struct! [value [g-error!]]

	g-type-class!: alias struct! [
		type						[g-type!]
	]

	g-type-instance!: alias struct! [
		class						[g-type-class!]
	]

	g-object!: alias struct! [
	;	type						[g-type-instance!]
			class					[g-type-class!]

		reference-count				[unsigned!]
	;	data						[g-data!]  ; TODO
	]

	#define g-initially-unowned!	g-object!

	g-closure!:						alias opaque!

	#define g-closure-notify! [
		function! [
			data					[handle!]
			closure					[g-closure!]
		]
	]

	; Signals

	#enum connect-flags! [
		connect-after:				1
		connect-swapped
	]


	#switch OS [
		Windows		[#define GThreads-library "libgthread-2.0-0.dll"]
		MacOSX		[#define GThreads-library "libgthread-2.0.dylib"]  ; TODO: check this
		#default	[#define GThreads-library "libgthread-2.0.so.0"]
	]
	#import [GThreads-library cdecl [
		; Global setup

		begin-threads: "g_thread_init" [					"Set up threading."
			functions			[handle!]
		]
	]]


	#switch OS [
		Windows		[#define GLib-library "libglib-2.0-0.dll"]
		MacOSX		[#define GLib-library "libglib-2.0.dylib"]  ; TODO: check this
		#default	[#define GLib-library "libglib-2.0.so.0"]
	]
	#import [GLib-library cdecl [
		; Memory management

		g-free: "g_free" [									"Release previously allocated memory."
			memory				[binary!]
		]
		g-free-error: "g_error_free" [						"Clean up error."
			error				[g-error!]
		]
	]]


	#switch OS [
		Windows		[#define GObject-library "libgobject-2.0-0.dll"]
		MacOSX		[#define GObject-library "libgobject-2.0.dylib"]  ; TODO: check this
		#default	[#define GObject-library "libgobject-2.0.so.0"]
	]
	#import [GObject-library cdecl [
		check-instance-type: "g_type_check_instance_is_a" [	"Check type of an object instance."
			instance			[g-type-instance!]
			type				[g-type!]
			return:				[g-logic!]
		]

		; Signals

		connect-signal-data: "g_signal_connect_data" [		"Hook up a callback to a signal."
			instance			[handle!]
			detailed-signal		[c-string!]
			handler				[integer!]					"g-callback!"
			data				[handle!]
			clear-data			[integer!]					"g-closure-notify!"
			flags				[connect-flags!]
			return:				[unsigned-long!]
		]
	]]


	; Higher level interface


	; Signals

	connect-signal: function ["Hook up a callback to a signal."
		instance			[handle!]
		detailed-signal		[c-string!]
		handler				[integer!]  "g-callback!"
		data				[handle!]
		return:				[unsigned-long!]
	][
		connect-signal-data instance detailed-signal handler data null 0
	]
	connect-signal-swapped: function ["Hook up a callback to a signal."
		instance			[handle!]
		detailed-signal		[c-string!]
		handler				[integer!]  "g-callback!"
		data				[handle!]
		return:				[unsigned-long!]
	][
		connect-signal-data instance detailed-signal handler data null connect-swapped
	]

]


; Global setup

g/begin-threads null  ; Set up threading
