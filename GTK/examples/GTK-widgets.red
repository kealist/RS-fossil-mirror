Red [
	Title:		"GTK+ widgets overview"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011,2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red >= 0.3.2
		%GTK.red
	}
	Tabs:		4
]

#include %../GTK.red

do-line: function [
	field [integer!]  ; "entry!"
][
	print ["Input:" get-field-text field]
]

text: "Quit"

view/title compose [
	"Label"
{Multi-line
label.}
	[
		"Implicit Horizontal Box"
		line: field "Input Field" [do-line face]
		button "Print" [do-line line]
	]

	lines: area
{Multi-line
input field.}
	hbox [
		"Explicit Horizontal Box"
		button "Print" [print ["Input:" get-area-text lines]]
	]

	button (text) close
] "Red Widgets Overview"
