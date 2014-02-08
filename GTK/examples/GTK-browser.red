Red [
	Title:		"GTK+ GUI browser"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red >= 0.3.2
		%input-output.red
		%GTK.red

		%common.red
		%C-library/ANSI.red
		%TNetStrings/TNetStrings.red
		%JSON/JSON.red
	}
	Notes: {
		Of course, this simple example is totally unsafe,
		except in trusted network environments.
	}
	Tabs:		4
]

#include %../../common/input-output.red
#include %../GTK.red

; Extras
#include %../../common/common.red
#include %../../C-library/ANSI.red
#include %../../TNetStrings/TNetStrings.red
#include %../../JSON/JSON.red
;#include %../../SQLite/SQLite.red
;#include %../../ZeroMQ-binding/ZeroMQ-binding.red

home: "http://red.esperconsultancy.nl/index.red"

go-view: function [
	spec		[block!]
][
	unless zero? box: parse-vbox window: actions/2  spec [
		unless zero? display [
			remove-face window display
		]
		set 'display box
		append-face window box
		show box
	]
]
go: function [
	face		[integer!]  ; "widget!"
	window		[integer!]  ; "box!"
][
	all [
		link: either button? face [get-button-text face] [get-field-text face]
		not empty? link
		script: read link
		either empty? code: load/all script [go-view []] [do code]
	]
]

execute: function [] [
	link: get-argument 1

	if window: view/only/title compose/deep [
			[
				"File/URL:" address: field (any [link home]) go
				button "Go" [go address window]
				button "Quit" close
			]
		] "Red GTK+ Browser"
	[
		actions/2: window
		set 'view :go-view
		go address window
		do-events
	]
]

display: 0
execute
