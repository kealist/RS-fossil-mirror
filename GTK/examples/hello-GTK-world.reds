Red/System [
	Title:		"Hello GTK+ example"
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
	Purpose: {
		This is the traditional Hello World example, showing
		the smallest possible program to output a message,
		in the GTK+ binding for Red/System.
	}
	Tabs:		4
]

#include %../GTK.reds

with gtk [view label "Hello, Red/System GTK+ world!"]
