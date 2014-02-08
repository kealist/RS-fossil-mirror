Red [
	Title:		"Very simple GTK+ IDE"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red >= 0.3.2
		%GTK.red

		%common.red
		%C-library/ANSI.red
		%input-output.red
		%TNetStrings/TNetStrings.red
		%JSON/JSON.red
	}
	Tabs:		4
]

#include %../GTK.red

; Extras
#include %../../common/common.red
#include %../../C-library/ANSI.red
#include %../../common/input-output.red
#include %../../TNetStrings/TNetStrings.red
#include %../../JSON/JSON.red
;#include %../../SQLite/SQLite.red
;#include %../../ZeroMQ-binding/ZeroMQ-binding.red

view-area: function [
	area		[integer!]  ; "widget!"
][
	all [
		script: get-area-text area
		not empty? code: load/all script
		view/only code
	]
]

execute: has [text script result] [
	view/title [
		text: area
		hbox [
			button "Do" [
				if all [
					script: get-area-text text
					not unset? set/any 'result do script
				][
					print ["==" mold :result]
				]
			]
			button "View" [view-area text]
			button "Quit" close
		]
	] "Red GTK+ IDE"
]

q: :quit

execute
