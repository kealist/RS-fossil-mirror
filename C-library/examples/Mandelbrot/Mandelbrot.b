#! /usr/bin/env boron
/*
	Mandelbrot fractal ASCII renderer
	Copyright (c) 2012 Kaj de Vos
	License: PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
*/

threshold: 16.0
max-iterations: 50000

mandelbrot: func [
	x		decimal!
	y		decimal!
	|		i cr ci zr zi zr2 zi2 value
][
	cr: sub y 0.5
	ci: x
	zr: zi: 0.0
	i: 1

	loop max-iterations [
		value: mul zr zi
		zr: add sub zr2: mul zr zr  zi2: mul zi zi  cr
		zi: add add value value ci

		if gt? add zr2 zi2  threshold [return i]

		++ i
	]
	0
]

start: now
y: -39

while [lt? y 40] [
	x: -39

	while [lt? x 40] [
		prin either zero? mandelbrot div x 40.0  div y 40.0 ['*'] [' ']

		++ x
	]
	print ""

	++ y
]

print ["Elapsed time:" sub now start]
