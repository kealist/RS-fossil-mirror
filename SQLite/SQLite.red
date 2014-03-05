Red [
	Title:		"SQLite Binding"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2014 Kaj de Vos. All rights reserved."
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
		SQLite 3
		%SQLite.reds
		%common/common.red
	}
	Tabs:		4
]


#system-global [#include %SQLite.reds]
#include %../common/common.red


; Data types

sqlite-integer!:			1
sqlite-float!:				2
sqlite-string!:				3
sqlite-binary!:				4
sqlite-none!:				5


; Memory management

memory-static:				0
memory-transient:			-1


; Error handling

status-ok:					0

error-sql:					1
error-internal:				2
error-permission:			3
error-abort:				4
error-busy:					5
error-locked:				6
error-memory:				7
error-read-only:			8
error-interrupt:			9
error-input-output:			10
error-corrupt:				11
error-not-found:			12
error-full:					13
error-opening:				14
error-protocol:				15
error-empty:				16
error-schema:				17
error-too-big:				18
error-constraint:			19
error-mismatch:				20
error-misuse:				21
error-no-lfs:				22
error-authorization:		23
error-format:				24
error-range:				25
error-no-db:				26

status-next-row:			100
status-done:				101


; Database management

sqlite!:					integer!

; Open VFS masks

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


version: routine ["Return SQLite version."
;	return:				[string!]
	/local				version
][
	version: sqlite/version
	SET_RETURN ((string/load version  (length? version) + 1  UTF-8))
]
source-version: routine ["Return SQLite source ID."
;	return:				[string!]
	/local				version
][
	version: sqlite/source-version
	SET_RETURN ((string/load version  (length? version) + 1  UTF-8))
]
version-number: routine ["Return SQLite version number."
	return:				[integer!]
][
	sqlite/version-number
]


; Error handling

status-of: routine ["Return status code."
	db					[integer!]  "sqlite!"
	return:				[integer!]  "status!"
][
	with sqlite [sqlite/status-of as sqlite! db]
]
extended-error-of: routine ["Return extended status code."
	db					[integer!]  "sqlite!"
	return:				[integer!]
][
	with sqlite [sqlite/extended-error-of as sqlite! db]
]
form-error: routine ["Return UTF-8 status message."
	db					[integer!]  "sqlite!"
;	return:				[string!]
	/local				text
][
	with sqlite [text: sqlite/form-error as sqlite! db]
	SET_RETURN ((string/load text  (length? text) + 1  UTF-8))
]
form-error-utf16: routine ["Return UTF-16 status message."
	db					[integer!]  "sqlite!"
	return:				[integer!]  "binary!"
][
	with sqlite [as-integer sqlite/form-error-utf16 as sqlite! db]
]


; Global setup and teardown

begin-sqlite: routine ["Set up global environment."
	return:				[integer!]  "status!"
][
	sqlite/begin-sqlite
]
end-sqlite: routine ["Clean up global environment."
	return:				[integer!]  "status!"
][
	sqlite/end-sqlite
]


; Memory management

sqlite-allocate: routine ["Allocate memory."
	size				[integer!]
	return:				[integer!]  "binary!"
][
	as-integer sqlite/sqlite-allocate size
]
sqlite-resize: routine ["Resize memory allocation."
	memory				[integer!]  "binary!"
	size				[integer!]
	return:				[integer!]  "binary!"
][
	as-integer sqlite/sqlite-resize as-binary memory  size
]
sqlite-free: routine ["Free allocated memory."
	memory				[integer!]  "binary!"
][
	sqlite/sqlite-free as-binary memory
]


; Database management

open-database: routine ["Open a database file name."
	file				[string!]
	return:				[integer!]  "sqlite!"
	/local string db-reference
][
	string: to-UTF8 file
	with sqlite [db-reference: declare sqlite-reference!]
	sqlite/open-database string db-reference
	free-any string
	as-integer db-reference/value
]
open-utf16: routine ["Open a UTF-16 database file name."
	file				[integer!]  "binary!"
	return:				[integer!]  "sqlite!"
	/local				db-reference
][
	with sqlite [db-reference: declare sqlite-reference!]
	sqlite/open-utf16 as-binary file  db-reference
	as-integer db-reference/value
]
open-vfs: routine ["Open a database file name via VFS."
	file				[string!]
	flags				[integer!]  "open-mask!"
	vfs					[string!]
	return:				[integer!]  "sqlite!"
	/local name string db-reference
][
	name: to-UTF8 file
	string: to-UTF8 vfs
	with sqlite [db-reference: declare sqlite-reference!]
	sqlite/open-vfs
		name
		db-reference
		flags
		string
	free-any name
	free-any string
	as-integer db-reference/value
]

close-database: routine ["Close database."
	db					[integer!]  "sqlite!"
	return:				[integer!]  "status!"
][
	with sqlite [sqlite/close-database as sqlite! db]
]


; SQL processing

do-sql: routine ["Execute SQL statements."
	db					[integer!]  "sqlite!"
	sql					[string!]
;	row-handler			[function! [
;							data	[handle!]
;							columns	[integer!]
;							values	[string-reference!]
;							names	[string-reference!]
;							return:	[sql-status!]
;						]]  "Callback, or NULL"
	row-handler			[integer!]
	data				[integer!]  "handle!, or NULL"
;	return:				[string! none!]  "Error message, or NONE"
	/local text status error-reference
][
	text: to-UTF8 sql
	error-reference: declare string-reference!

	with sqlite [status: do
		as sqlite! db
		text
		row-handler
		as-handle data
		error-reference
	]
	free-any text

	either as-logic status [
		SET_RETURN ((string/load error-reference/value  (length? error-reference/value) + 1  UTF-8))
;		sqlite-free as-binary error-reference/value
	][
		RETURN_NONE
	]
]

load-next: routine ["Compile a UTF-8 SQL statement."
	db					[integer!]  "sqlite!"
	sql					[string!]
;	tail				[integer!]  ; string-reference!, progress pointer, or NULL
	return:				[integer!]  "sql!"
	/local string statement
][
	string: to-UTF8 sql

	with sqlite [
		statement: declare sql-reference!
		sqlite/load-next
			as sqlite! db
			string
			1 + length? string  ; -1
			statement
			null  ; as string-reference! tail
	]
	free-any string
	as-integer statement/value
]
load-next-utf16: routine ["Compile a UTF-16 SQL statement."
	db					[integer!]  "sqlite!"
	sql					[string!]  "binary!"
;	tail				[integer!]  ; binary-reference!, progress pointer, or NULL
	return:				[integer!]  "sql!"
	/local				statement
][
	with sqlite [
		statement: declare sql-reference!
		sqlite/load-next-utf16
			as sqlite! db
			string/rs-head sql
			(string/rs-length? sql) << 1
			statement
			null  ; as binary-reference! tail
	]
	as-integer statement/value
]
end-sql: routine ["Clean up SQL statement."
	sql					[integer!]  "sql!"
	return:				[integer!]  "status!"
][
	with sqlite [sqlite/end-sql as sql! sql]
]

do-next: routine ["Execute SQL statement."
	sql					[integer!]  "sql!"
	return:				[integer!]  "status!"
][
	with sqlite [sqlite/do-next as sql! sql]
]
clear-sql: routine ["Reset SQL statement for next evaluation."
	sql					[integer!]  "sql!"
	return:				[integer!]  "status!"
][
	with sqlite [sqlite/clear-sql as sql! sql]
]


; Binding

unbind: routine ["Clear bindings to SQL statement."
	sql					[integer!]  "sql!"
	return:				[integer!]  "status!"
][
	with sqlite [sqlite/unbind as sql! sql]
]


count-parameters: routine ["Highest parameter index in SQL statement."
	sql					[integer!]  "sql!"
	return:				[integer!]
][
	with sqlite [sqlite/count-parameters as sql! sql]
]
find-parameter: routine ["Index of parameter within SQL statement."
	sql					[integer!]  "sql!"
	name				[string!]
	return:				[integer!]  "0: no match"
	/local string index
][
	string: to-UTF8 name
	with sqlite [index: sqlite/find-parameter as sql! sql  string]
	free-any string
	index
]
pick-symbol: routine ["Name of parameter in SQL statement."
	sql					[integer!]  "sql!"
	index				[integer!]
;	return:				[string!]  ; TODO: NULL: no match
	/local				name
][
	with sqlite [name: sqlite/pick-symbol as sql! sql  index]
	SET_RETURN ((string/load name  (length? name) + 1  UTF-8))
]


bind-none: routine ["Bind to NULL."
	sql					[integer!]  "sql!"
	index				[integer!]  "1 based"
	return:				[integer!]  "status!"
][
	with sqlite [sqlite/bind-none as sql! sql  index]
]
bind-zero: routine ["Bind zero-filled binary value."
	sql					[integer!]  "sql!"
	index				[integer!]
	size				[integer!]
	return:				[integer!]  "status!"
][
	with sqlite [sqlite/bind-zero as sql! sql  index size]
]

sqlite-bind: routine ["Bind dynamic value."
	sql					[integer!]  "sql!"
	index				[integer!]
	value				[integer!]  "value!"
	return:				[integer!]  "status!"
][
	with sqlite [sqlite/bind as sql! sql  index as value! value]
]

bind-integer: routine ["Bind integer."
	sql					[integer!]  "sql!"
	index				[integer!]
	value				[integer!]
	return:				[integer!]  "status!"
][
	with sqlite [sqlite/bind-integer as sql! sql  index value]
]
;bind-integer64: routine ["Bind 64-bits integer."
;	sql					[integer!]  "sql!"
;	index				[integer!]
;	value				[integer64!]
;	return:				[integer!]  "status!"
;][
;	with sqlite [sqlite/bind-integer64 as sql! sql  index value]
;]
;bind-float: routine ["Bind floating point value."
;	sql					[integer!]  "sql!"
;	index				[integer!]
;	value				[float!]
;	return:				[integer!]  "status!"
;][
;	with sqlite [sqlite/bind-float as sql! sql  index value]
;]
bind-binary: routine ["Bind binary value."
	sql					[integer!]  "sql!"
	index				[integer!]
	value				[integer!]  "binary!"
	size				[integer!]  "Negative: null-terminated"
	return:				[integer!]  "status!"
][
	with sqlite [sqlite/bind-binary as sql! sql  index  as-binary value  size  memory-transient]
]
bind-string: routine ["Bind text."
	sql					[integer!]  "sql!"
	index				[integer!]
	value				[string!]
	return:				[integer!]  "status!"
	/local string status
][
	string: to-UTF8 value

	with sqlite [
		status: sqlite/bind-string
			as sql! sql
			index
			string
			1 + length? string  ; -1
			memory-transient
	]
	free-any string
	status
]
bind-utf16: routine ["Bind UTF-16 text."
	sql					[integer!]  "sql!"
	index				[integer!]
	value				[string!]  "binary!"
	size				[integer!]  "Negative: null-terminated"
	return:				[integer!]  "status!"
][
	with sqlite [sqlite/bind-utf16
		as sql! sql
		index
		string/rs-head value
		(string/rs-length? value) << 1
		memory-transient
	]
]


; Result row processing

count-columns: routine ["Number of columns in the result row."
	row					[integer!]  "sql!"
	return:				[integer!]
][
	with sqlite [sqlite/count-columns as sql! row]
]

pick-size: routine ["Column value size in bytes."
	row					[integer!]  "sql!"
	column				[integer!]  "0 based"
	return:				[integer!]
][
	with sqlite [sqlite/pick-size as sql! row  column]
]
pick-utf16-size: routine ["UTF-16 column value size in bytes."
	row					[integer!]  "sql!"
	column				[integer!]
	return:				[integer!]
][
	with sqlite [sqlite/pick-utf16-size as sql! row  column]
]

pick-name: routine ["Column name."
	row					[integer!]  "sql!"
	column				[integer!]
;	return:				[string!]
	/local				name
][
	with sqlite [name: sqlite/pick-name as sql! row  column]
	SET_RETURN ((string/load name  (length? name) + 1  UTF-8))
]
pick-utf16-name: routine ["UTF-16 column name."
	row					[integer!]  "sql!"
	column				[integer!]
	return:				[integer!]  "binary!"
][
	with sqlite [as-integer sqlite/pick-utf16-name as sql! row  column]
]

pick-type: routine ["Column type."
	row					[integer!]  "sql!"
	column				[integer!]
	return:				[integer!]  "type!"
][
	with sqlite [sqlite/pick-type as sql! row  column]
]
sqlite-pick: routine ["Extract dynamic column value."
	row					[integer!]  "sql!"
	column				[integer!]
	return:				[integer!]  "value!"
][
	with sqlite [as-integer sqlite/pick as sql! row  column]
]

pick-integer: routine ["Extract integer column value."
	row					[integer!]  "sql!"
	column				[integer!]
	return:				[integer!]
][
	with sqlite [sqlite/pick-integer as sql! row  column]
]
;pick-integer64: routine ["Extract 64-bits integer column value."
;	row					[integer!]  "sql!"
;	column				[integer!]
;	return:				[integer64!]
;][
;	with sqlite [sqlite/pick-integer64 as sql! row  column]
;]
;pick-float: routine ["Extract floating point column value."
;	row					[integer!]  "sql!"
;	column				[integer!]
;	return:				[float!]
;][
;	with sqlite [sqlite/pick-float as sql! row  column]
;]
pick-binary: routine ["Extract binary column value."
	row					[integer!]  "sql!"
	column				[integer!]
	return:				[integer!]  "binary!"
][
	with sqlite [as-integer sqlite/pick-binary as sql! row  column]
]
pick-string: routine ["Extract column text."
	row					[integer!]  "sql!"
	column				[integer!]
;	return:				[string!]
	/local				text
][
	with sqlite [text: sqlite/pick-string as sql! row  column]
	SET_RETURN ((string/load text  (length? text) + 1  UTF-8))
]
pick-utf16: routine ["Extract UTF-16 column value."
	row					[integer!]  "sql!"
	column				[integer!]
	return:				[integer!]  "binary!"
][
	with sqlite [as-integer sqlite/pick-utf16 as sql! row  column]
]
