Red/System [
	Title:		"Fibonacci numbers"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2012,2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red/System >= 0.2.5
		%C-library/ANSI.reds
	}
	Tabs:		4
]

#include %../../ANSI.reds

#define parameter 40

fibonacci: function [
	n		[integer!]
	return:	[integer!]
][
	either n < 2 [n] [(fibonacci n - 1) + fibonacci n - 2]
]

start: now-time null
f: fibonacci parameter

print-line [
	"Fibonacci " parameter ": " f newline
	"Elapsed time: " subtract-time  now-time null  start  newline
	"Process time: " get-process-seconds
]
