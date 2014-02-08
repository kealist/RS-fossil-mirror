#! /usr/bin/env boron
/*
	Fibonacci numbers
	Copyright (c) 2012 Kaj de Vos
	License: PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
*/

parameter: 40

fibonacci: func [n int!] [
	either lt? n 2 [n] [add fibonacci sub n 1  fibonacci sub n 2]
]

start: now

prin ["Fibonacci" parameter] print [":" fibonacci parameter]
print ["Elapsed time:" sub now start]
