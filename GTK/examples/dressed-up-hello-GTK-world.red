Red [
	Title:		"Hello GTK+ example, with title, icon and close button"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2013 Kaj de Vos"
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

view/title [
	"Hello, Red GTK+ world!"
	button "Quit" close
] "Hello World"
