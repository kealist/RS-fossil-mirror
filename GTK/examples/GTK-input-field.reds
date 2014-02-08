Red/System [
	Title:		"GTK+ input field example"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011,2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red/System >= 0.3.1
		%GTK.reds
	}
	Tabs:		4
]

#include %../GTK.reds

with gtk [
	action: function [
		[cdecl]
		widget		[widget!]
		data		[entry!]
	][
		print ["Input: "  get-entry-text data  newline]
	]

	line: field ["Here" :action]

	view [
		170 90  position-center
		"Red/System GTK+ Input Field"
		vbox [
			"Input:"
			line
			fixed button [50 25  "Print"  :action line]
		]
	]
]
