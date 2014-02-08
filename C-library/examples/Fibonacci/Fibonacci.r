#! /usr/bin/env rebol
REBOL [
	Title:		"Fibonacci numbers"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2012 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
;	Needs:		"REBOL 3 or 2"
	Tabs:		4
]

parameter: 40

fibonacci: func [n [integer!]] [
	either n < 2 [n] [(fibonacci n - 1) + fibonacci n - 2]
]

start: now/time/precise

prin ["Fibonacci" parameter] print [":" fibonacci parameter]
print ["Elapsed time:" now/time/precise - start]
