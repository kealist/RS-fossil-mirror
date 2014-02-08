Red [
	Title:		"Fibonacci numbers"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2012,2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red >= 0.3.2
		%C-library/ANSI.red
	}
	Tabs:		4
]

#include %../../ANSI.red

parameter: 40

start: now/precise

fibonacci: function [
	n		[integer!]
	return:	[integer!]
][
	either n < 2 [n] [(fibonacci n - 1) + fibonacci n - 2]
]

prin ["Fibonacci" parameter] print [":" fibonacci parameter  newline
	"Elapsed seconds:" subtract-time now/precise start  newline
	"Process time:" get-process-seconds
]
