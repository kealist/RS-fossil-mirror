#! /usr/bin/env rebol
REBOL [
	Title:		"Mandelbrot fractal ASCII renderer"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2012 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
;	Needs:		"REBOL 3 or 2"
	Tabs:		4
]

threshold: 16.0
max-iterations: 50'000

mandelbrot: func [
	x		[decimal!]
	y		[decimal!]
	/local	i cr ci zr zi zr2 zi2 value
][
	cr: y - 0.5
	ci: x
	zr: zi: 0.0

	repeat i max-iterations [
		value: zr * zi
		zr: (zr2: zr * zr) - (zi2: zi * zi) + cr
		zi: value + value + ci

		if zr2 + zi2 > threshold [return i]
	]
	0
]

start: now/time/precise

for y -39 39 1 [
	for x -39 39 1 [
		prin either zero? mandelbrot x / 40.0  y / 40.0 [#"*"] [#" "]
	]
	print ""
]

print ["Elapsed time:" now/time/precise - start]
