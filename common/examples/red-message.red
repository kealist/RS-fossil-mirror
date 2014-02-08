Red [
	Title:		"Graphical Red distribution with messaging"
	Author:		["Nenad Rakocevic" "Kaj de Vos"]
	Rights:		"Copyright (c) 2012-2013 Nenad Rakocevic. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
	}
	Needs: {
		%common/input-output.red
		%console.red
		%C-library/ANSI.red
		%SQLite/SQLite.red
		%ZeroMQ-binding/ZeroMQ-binding.red
		%GTK/GTK.red
		%TNetStrings/TNetStrings.red
		%JSON/JSON.red
	}
	Tabs:		4
]


#include %../input-output.red

; Extras
#include %../../C-library/ANSI.red
#include %../../SQLite/SQLite.red
#include %../../ZeroMQ-binding/ZeroMQ-binding.red
#include %../../GTK/GTK.red
#include %../../TNetStrings/TNetStrings.red
#include %../../JSON/JSON.red

#include %console.red
