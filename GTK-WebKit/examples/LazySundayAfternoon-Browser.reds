Red/System [
	Title:		"WebKitGTK+ browser example"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011,2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red/System >= 0.3.1
		%GTK-WebKit.reds
	}
	Tabs:		4
]

#include %../GTK-WebKit.reds

home: "http://www.red-lang.org/"

with gtk [
	address: function [
		[cdecl]
		field		[entry!]
		browser		[scrolled-window!]
	][
		web-browse  web-get-view browser  get-entry-text field
	]

	browser: browse home

	view [
		maximize
		"Lazy Sunday Afternoon Browser"
		vbox [0
			field [home  :address browser] 0
			browser full 0
		]
	]
]
