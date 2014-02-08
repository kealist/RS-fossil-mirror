Red [
	Title:		"GTK+ live coding example"
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

execute: function [] [
	if window: view/only/title [
			text: area
			hbox [
				button "View" [
					any [
						none? script: get-area-text text
						empty? code: load/all script
						zero? box: parse-vbox window code
						(
							unless zero? stage [
								remove-face window stage
							]
							append-face window stage: box
							show stage
						)
					]
				]
				button "Quit" close
			]
		] "Red GTK+ Live Coding"
	[
		stage: 0
		do-events
	]
]

execute
