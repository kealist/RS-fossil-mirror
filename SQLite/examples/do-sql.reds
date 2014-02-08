Red/System [
	Title:		"Quick start SQLite example"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		%C-library/ANSI.reds
		%SQLite.reds
	}
	Purpose: {
		Show a simple way to start programming SQLite, similar to this
		introductory documentation:
		http://sqlite.org/quickstart.html
	}
	Example: {
		do-sql database.sqlite "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
	}
	Tabs:		4
]


#include %../../C-library/ANSI.reds
#include %../SQLite.reds


with sqlite [

	log-error: function ["Log SQLite error."
		db			[sqlite!]
	][
		print ["Error: "  form-error db  newline]
	]

	data!: alias struct! [
		count		[integer!]
	]

	handle-row: function [[cdecl]
		"Process a result row."
		data		[data!]
		columns		[integer!]
		values		[string-reference!]
		names		[string-reference!]
		return:		[integer!]  "0: OK"
	][
		data/count: data/count + 1
		print ["Row number: " data/count newline]

		; Print all name/value pairs of the columns that have values

		while [as-logic columns] [
			if as-logic values/value [
				print [names/value ": " values/value newline]
			]
			columns: columns - 1
			names: names + 1
			values: values + 1
		]
		print newline

		status-ok  ; Keep processing
	]

	argument:		as-c-string 0

	db-reference:	declare sqlite-reference!
	db:				as sqlite! 0
	status:			status-ok
	end:			status-ok
	error:			declare string-reference!
	data:			declare data!

	switch get-args-count [
	0 [
		print-line [
			"SQLite version: "			version  newline
			"SQLite version number: "	version-number  newline
			"SQLite source ID: "		source-version
		]
	]
	2 [
		; Open (or create) the database
		argument: get-argument 1
		status: open-database argument db-reference
		end-argument argument
		db: db-reference/value

		either as-logic status [
			log-error db
		][
			; Execute the SQL statements
			argument: get-argument 2
			data/count: 0
			status: do db
				argument
				as-integer :handle-row
				as-handle data
				error
			end-argument argument

			either as-logic status [
				print ["SQL error: " error/value newline]
				sqlite-free as-binary error/value
				;log-error db
			][
				print [data/count " rows processed" newline]
			]
		]

		; Close the database
		end: close-database db

		; Return the first occurred error code, if any
		if as-logic end [
			log-error db
			if zero? status [quit end]
		]
		quit status
	]
	default [
		argument: get-argument 0
		print-wide ["Usage:" argument "<database> <SQL statements>" newline]
		end-argument argument

		quit 1
	]]

]
