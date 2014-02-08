Red/System [
	Title:		"Hello GTK+ example, traditional version"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red/System >= 0.3.1
		%GTK.reds
	}
	Purpose: {
		This is the traditional Hello World example, showing
		the smallest possible program to output a message,
		in the GTK+ binding for Red/System.
		This is the version similar to how it would be written
		in other bindings for other programming languages.
	}
	Tabs:		4
]

#include %../GTK.reds

with gtk [
	comment {  ; Already taken care of by %GTK.reds
		argc: system/args-count
		argv-reference: declare handle-reference!
		argv-reference/value: as-handle system/args-list

		begin :argc argv-reference
	}

	window*: make-window window-top-level
	label*: as label! 0

	either as-logic window* [
		set-container-border  as container! window*  10

		label*: make-label "Good riddens!"

		either as-logic label* [
			container-append  as container! window*  as widget! label*
		][
			print-line "Failed to create label."
		]

		g/connect-signal  as-handle window*  "destroy"  as-integer :quit  null
		show-all as widget! window*
		do-events
	][
		print-line "Failed to create window."
	]
]
