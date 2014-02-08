Red/System [
	Title:		"Champlain map browser example"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011,2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red/System >= 0.3.1
		%GTK-Champlain.reds
	}
	Tabs:		4
]

#include %../GTK-Champlain.reds

with gtk [
	view [
		maximize
		"Champlain Map Browser"
		champlain-map
	]
]
