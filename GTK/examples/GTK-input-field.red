Red [
	Title:		"GTK+ input field example"
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

engage: function [
	field [integer!]  ; "entry!"
][
	print ["Input:" get-field-text field]
]
view/title [
	"Input:" line: field "Here" [engage face]
	button "Print" [engage line]
] "Red GTK+ Input Field"
