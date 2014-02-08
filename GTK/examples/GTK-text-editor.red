Red [
	Title:		"GTK+ text editor"
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
	}
	Tabs:		4
]

#include %../../common/input-output.red
#include %../GTK.red

link: get-argument 1

load-file: function [
	field		[integer!]  ; "entry!"
	area		[integer!]  ; "widget!"
][
	all [
		link: get-field-text field
		not empty? link
		data: read link
		set-area-text area data
	]
]
view/title compose/deep [
	[
		"File/URL:" address: field (any [link ""]) [load-file face text]
		button "Load" [load-file address text]
		button "Save" [
			all [
				link: get-field-text address
				not empty? link
				data: get-area-text text
				write link data
			]
		]
		button "Quit" close
	]
	text: area (any [
		all [
			link
			not empty? link
			read link
		]
		""
	])
] "Red GTK+ Text Editor"
