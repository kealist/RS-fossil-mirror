Red [
	Title:		"Quick start SQLite example"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		%SQLite.red
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


#include %../SQLite.red


log-error: function ["Log SQLite error."
	db			[sqlite!]
][
	print ["Error:" form-error db]
]

#system-global [
	with sqlite [

		data!: alias struct! [
			count		[integer!]
		]
		data:			declare data!

		handle-row: function [				"Process a result row."
			[cdecl]
			data		[data!]
			columns		[integer!]
			values		[string-reference!]
			names		[string-reference!]
			return:		[integer!]			"0: OK"
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

	]
]

handler: routine [
	return:		[integer!]  "function!"
][
	as-integer :handle-row
]
counter: routine [
	return:		[integer!]  "data!"
][
	as-integer data
]

begin: routine [] [
	data/count: 0
]
count: routine [
	return:		[integer!]
][
	data/count
]


switch/default get-args-count [
0 [
	print ["SQLite version:"		version]
	print ["SQLite version number:"	version-number]
	print ["SQLite source ID:"		source-version]
]
2 [
	; Open (or create) the database
	db: open-database get-argument 1

	either zero? status: status-of db [
		; Execute the SQL statements

		begin

		either error: do-sql db  get-argument 2  handler counter [
			status: status-of db

			print ["SQL error:" error]
			;log-error db
		][
			print [count "rows processed"]
		]
	][
		log-error db
	]

	; Close the database
	end: close-database db

	; Return the first occurred error code, if any
	unless zero? end [
		log-error db
		if zero? status [quit/return end]
	]
	quit/return status
]][
	print ["Usage:" get-argument 0 "<database> <SQL statements>"]

	quit/return 1
]
