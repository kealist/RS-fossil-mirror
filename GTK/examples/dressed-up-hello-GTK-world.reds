Red/System [
	Title:		"Hello GTK+ example, with title, icon and close button"
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
	Tabs:		4
]

#include %../GTK.reds

with gtk [
	status: version-mismatch 2 0 0

	unless as-logic status [status: "sufficient"]
	print ["GTK version: " status newline]


	view [
		170 90  position-center
		"Hello World"
		icon "Red-48x48.png"
		vbox [
			"Hello, Red/System GTK+ world!"
			hbox button [50 25  "Quit" :quit]
		]
	]
]
