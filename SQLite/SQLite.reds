Red/System [
	Title:		"SQLite Binding"
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
		SQLite 3
		%common/common.reds
	}
	Tabs:		4
]


#include %../common/common.reds


sqlite: context [

	; Data types

	#enum type! [
		sqlite-integer!:			1
		sqlite-float!
		sqlite-string!
		sqlite-binary!
		sqlite-none!
	]

	; Dynamic type

	value!:							alias opaque!


	; Memory management

	#enum memory! [
		memory-static
		memory-transient:			-1
	]


	; Error handling

	#enum status! [
		status-ok

		error-sql
		error-internal
		error-permission
		error-abort
		error-busy
		error-locked
		error-memory
		error-read-only
		error-interrupt
		error-input-output
		error-corrupt
		error-not-found
		error-full
		error-opening
		error-protocol
		error-empty
		error-schema
		error-too-big
		error-constraint
		error-mismatch
		error-misuse
		error-no-lfs
		error-authorization
		error-format
		error-range
		error-no-db

		status-next-row:			100
		status-done
	]


	; Database management

	sqlite!:						alias opaque!
	sqlite-reference!:				alias struct! [value [sqlite!]]

	; Open VFS masks

	#enum open-mask! [
		open-read-only:				00000001h
		open-read-write:			00000002h
		open-create:				00000004h
		open-delete-on-close:		00000008h
		open-exclusive:				00000010h
		open-auto-proxy:			00000020h
		open-uri:					00000040h
		open-main-db:				00000100h
		open-temporary-db:			00000200h
		open-transient-db:			00000400h
		open-main-journal:			00000800h
		open-temporary-journal:		00001000h
		open-subjournal:			00002000h
		open-master-journal:		00004000h
		open-no-mutex:				00008000h
		open-full-mutex:			00010000h
		open-shared-cache:			00020000h
		open-private-cache:			00040000h
		open-wal:					00080000h
	]


	; SQL processing

	sql!:							alias opaque!
	sql-reference!:					alias struct! [value [sql!]]


	#switch OS [
		Windows		[#define SQLite-library "sqlite3.dll"]
		MacOSX		[#define SQLite-library "libsqlite3.dylib"]
		#default	[#define SQLite-library "libsqlite3.so.0"]
	]
	#import [SQLite-library cdecl [
		version: "sqlite3_libversion" [						"Return SQLite version."
			return:				[c-string!]
		]
		source-version: "sqlite3_sourceid" [				"Return SQLite source ID."
			return:				[c-string!]
		]
		version-number: "sqlite3_libversion_number" [		"Return SQLite version number."
			return:				[integer!]
		]


		; Error handling

		status-of: "sqlite3_errcode" [						"Return status code."
			db					[sqlite!]
			return:				[status!]
		]
		extended-error-of: "sqlite3_extended_errcode" [		"Return extended status code."
			db					[sqlite!]
			return:				[integer!]
		]
		form-error: "sqlite3_errmsg" [						"Return UTF-8 status message."
			db					[sqlite!]
			return:				[c-string!]
		]
		form-error-utf16: "sqlite3_errmsg16" [				"Return UTF-16 status message."
			db					[sqlite!]
			return:				[binary!]
		]


		; Global setup and teardown

		begin-sqlite: "sqlite3_initialize" [				"Set up global environment."
			return:				[status!]
		]
		end-sqlite: "sqlite3_shutdown" [					"Clean up global environment."
			return:				[status!]
		]


		; Memory management

		sqlite-allocate: "sqlite3_malloc" [					"Allocate memory."
			size				[integer!]
			return:				[binary!]
		]
		sqlite-resize: "sqlite3_realloc" [					"Resize memory allocation."
			memory				[binary!]
			size				[integer!]
			return:				[binary!]
		]
		sqlite-free: "sqlite3_free" [						"Free allocated memory."
			memory				[binary!]
		]


		; Database management

		open-database: "sqlite3_open" [						"Open a UTF-8 database file name."
			file				[c-string!]
			db-reference		[sqlite-reference!]
			return:				[status!]
		]
		open-utf16: "sqlite3_open16" [						"Open a UTF-16 database file name."
			file				[binary!]
			db-reference		[sqlite-reference!]
			return:				[status!]
		]
		open-vfs: "sqlite3_open_v2" [						"Open a UTF-8 database file name via VFS."
			file				[c-string!]
			db-reference		[sqlite-reference!]
			flags				[open-mask!]
			vfs					[c-string!]
			return:				[status!]
		]

		close-database: "sqlite3_close" [					"Close database."
			db					[sqlite!]
			return:				[status!]
		]


		; SQL processing

		do: "sqlite3_exec" [  ; Execute SQL statements.
			db					[sqlite!]
			sql					[c-string!]
;			row-handler			[function! [
;									data	[handle!]
;									columns	[integer!]
;									values	[string-reference!]
;									names	[string-reference!]
;									return:	[sql-status!]
;								]]							"Callback, or NULL"
			row-handler			[integer!]
			data				[handle!]					"Or NULL"
			error-reference		[string-reference!]			"Message pointer, or NULL"
			return:				[status!]
		]

		load-next: "sqlite3_prepare_v2" [					"Compile a UTF-8 SQL statement."
			db					[sqlite!]
			sql					[c-string!]
			size				[integer!]					"Negative: null-terminated"
			statement			[sql-reference!]
			tail				[string-reference!]			"Progress pointer, or NULL"
			return:				[status!]
		]
		load-next-utf16: "sqlite3_prepare16_v2" [			"Compile a UTF-16 SQL statement."
			db					[sqlite!]
			sql					[binary!]
			size				[integer!]					"Negative: null-terminated"
			statement			[sql-reference!]
			tail				[binary-reference!]			"Progress pointer, or NULL"
			return:				[status!]
		]
		end-sql: "sqlite3_finalize" [						"Clean up SQL statement."
			sql					[sql!]
			return:				[status!]
		]

		do-next: "sqlite3_step" [							"Execute SQL statement."
			sql					[sql!]
			return:				[status!]
		]
		clear-sql: "sqlite3_reset" [						"Reset SQL statement for next evaluation."
			sql					[sql!]
			return:				[status!]
		]


		; Binding

		unbind: "sqlite3_clear_bindings" [					"Clear bindings to SQL statement."
			sql					[sql!]
			return:				[status!]
		]


		count-parameters: "sqlite3_bind_parameter_count" [	"Highest parameter index in SQL statement."
			sql					[sql!]
			return:				[integer!]
		]
		find-parameter: "sqlite3_bind_parameter_index" [	"Index of parameter within SQL statement."
			sql					[sql!]
			name				[c-string!]
			return:				[integer!]					"0: no match"
		]
		pick-symbol: "sqlite3_bind_parameter_name" [		"Name of parameter in SQL statement."
			sql					[sql!]
			index				[integer!]
			return:				[c-string!]					"NULL: no match"
		]


		bind-none: "sqlite3_bind_null" [					"Bind to NULL."
			sql					[sql!]
			index				[integer!]					"1 based"
			return:				[status!]
		]
		bind-zero: "sqlite3_bind_zeroblob" [				"Bind zero-filled binary value."
			sql					[sql!]
			index				[integer!]
			size				[integer!]
			return:				[status!]
		]

		bind: "sqlite3_bind_value" [						"Bind dynamic value."
			sql					[sql!]
			index				[integer!]
			value				[value!]
			return:				[status!]
		]

		bind-integer: "sqlite3_bind_int" [					"Bind integer."
			sql					[sql!]
			index				[integer!]
			value				[integer!]
			return:				[status!]
		]
		bind-integer64: "sqlite3_bind_int64" [				"Bind 64-bits integer."
			sql					[sql!]
			index				[integer!]
			value				[integer64!]
			return:				[status!]
		]
		bind-float: "sqlite3_bind_double" [					"Bind floating point value."
			sql					[sql!]
			index				[integer!]
			value				[float!]
			return:				[status!]
		]
		bind-binary: "sqlite3_bind_blob" [					"Bind binary value."
			sql					[sql!]
			index				[integer!]
			value				[binary!]
			size				[integer!]					"Negative: null-terminated"
;			free				[function! [value [binary!]]]
			free				[integer!]
			return:				[status!]
		]
		bind-string: "sqlite3_bind_text" [					"Bind text."
			sql					[sql!]
			index				[integer!]
			value				[c-string!]
			size				[integer!]					"Negative: null-terminated"
;			free				[function! [value [binary!]]]
			free				[integer!]
			return:				[status!]
		]
		bind-utf16: "sqlite3_bind_text16" [					"Bind UTF-16 text."
			sql					[sql!]
			index				[integer!]
			value				[binary!]
			size				[integer!]					"Negative: null-terminated"
;			free				[function! [value [binary!]]]
			free				[integer!]
			return:				[status!]
		]


		; Result row processing

		count-columns: "sqlite3_column_count" [				"Number of columns in the result row."
			row					[sql!]
			return:				[integer!]
		]

		pick-size: "sqlite3_column_bytes" [					"Column value size in bytes."
			row					[sql!]
			column				[integer!]					"0 based"
			return:				[integer!]
		]
		pick-utf16-size: "sqlite3_column_bytes16" [			"UTF-16 column value size in bytes."
			row					[sql!]
			column				[integer!]
			return:				[integer!]
		]

		pick-name: "sqlite3_column_name" [					"Column name."
			row					[sql!]
			column				[integer!]
			return:				[c-string!]
		]
		pick-utf16-name: "sqlite3_column_name16" [			"UTF-16 column name."
			row					[sql!]
			column				[integer!]
			return:				[binary!]
		]

		pick-type: "sqlite3_column_type" [					"Column type."
			row					[sql!]
			column				[integer!]
			return:				[type!]
		]
		pick: "sqlite3_column_value" [						"Extract dynamic column value."
			row					[sql!]
			column				[integer!]
			return:				[value!]
		]

		pick-integer: "sqlite3_column_int" [				"Extract integer column value."
			row					[sql!]
			column				[integer!]
			return:				[integer!]
		]
		pick-integer64: "sqlite3_column_int64" [			"Extract 64-bits integer column value."
			row					[sql!]
			column				[integer!]
			return:				[integer64!]
		]
		pick-float: "sqlite3_column_double" [				"Extract floating point column value."
			row					[sql!]
			column				[integer!]
			return:				[float!]
		]
		pick-binary: "sqlite3_column_blob" [				"Extract binary column value."
			row					[sql!]
			column				[integer!]
			return:				[binary!]
		]
		pick-string: "sqlite3_column_text" [				"Extract column text."
			row					[sql!]
			column				[integer!]
			return:				[c-string!]
		]
		pick-utf16: "sqlite3_column_text16" [				"Extract UTF-16 column value."
			row					[sql!]
			column				[integer!]
			return:				[binary!]
		]
	]]

]
