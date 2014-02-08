Red/System [
	Title:		"6502 CPU emulator example"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 1995,1996,2012 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red/System
		%machine.reds
		%cpu.reds
	}
	Purpose: {
		This is a simple example of a main loop using the 6502 emulator.
	}
	Example: {
		6502
	}
	Tabs:		4
]


#include %../machine.reds

#define do-events [
	forever [tick]
]

#include %../cpu.reds
