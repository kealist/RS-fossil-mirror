Red/System [
	Title:		"Mandelbrot fractal ASCII renderer"
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

#define threshold		16.0
#define max-iterations	50'000

mandelbrot: function [
	x		[float!]
	y		[float!]
	return:	[integer!]
	/local	i cr ci zr zi zr2 zi2 value
][
	cr: y - 0.5
	ci: x
	zr: 0.0
	zi: 0.0
	i: 1

	until [
		value: zr * zi
		zr2: zr * zr
		zi2: zi * zi
		zr: zr2 - zi2 + cr
		zi: value + value + ci

		if zr2 + zi2 > threshold [return i]

		i: i + 1
		i > max-iterations
	]
	0
]

start: now-time null

x: 0.0
y: -39.0

until [
	x: -39.0

	until [
		either zero? mandelbrot x / 40.0  y / 40.0 [print #"*"] [print #" "]

		x: x + 1.0
		x > 39.0
	]
	print newline

	y: y + 1.0
	y > 39.0
]

print-line [
	"Elapsed time: " subtract-time  now-time null  start  newline
	"Process time: " get-process-seconds
]
