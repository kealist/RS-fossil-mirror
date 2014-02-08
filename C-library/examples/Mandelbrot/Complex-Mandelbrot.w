World [
	Title:		"Mandelbrot fractal ASCII renderer"
	Author: {
		Kaj de Vos
		Adapted from Erik Wrenholt and John Niclasen
		http://www.timestretch.com/article/mandelbrot_fractal_benchmark
	}
	Rights:		"Copyright (c) 2012 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs:		"World"
	Tabs:		4
]

threshold: 4.0
max-iterations: 50'000

mandelbrot: func [
	c		[complex!]
	/local	i z
][
	z: 0i

	repeat i max-iterations [
		z: z * z + c

		if threshold < abs z [return i]
	]
	0
]

start: now/time/precise

for y -59 19 1 [
	for x -39 39 1 [
		prin either zero? mandelbrot x * 1i + y / 40 [#"*"] [#" "]
	]
	print ""
]

print ["Elapsed time:" now/time/precise - start]
