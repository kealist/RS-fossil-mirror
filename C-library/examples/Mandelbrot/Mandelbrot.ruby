#!/usr/bin/env ruby

#	Mandelbrot fractal ASCII renderer
#	Copyright (c) 2012 Kaj de Vos
#	Adapted from Erik Wrenholt
#		http://www.timestretch.com/article/mandelbrot_fractal_benchmark
#	License: PD/CC0
#		http://creativecommons.org/publicdomain/zero/1.0/

Threshold = 16.0
MaxIterations = 50000

def mandelbrot x, y
	cr = y - 0.5
	ci = x
	zr = zi = 0.0
	i = 1

	begin
		value = zr * zi
		zr = (zr2 = zr * zr) - (zi2 = zi * zi) + cr
		zi = value + value + ci

		return i if zr2 + zi2 > Threshold

		i += 1
	end until i > MaxIterations
	0
end

start = Time.now

for y in -39..39 do
	for x in -39..39 do
		print mandelbrot(x / 40.0, y / 40.0) == 0 ? '*' : ' '
	end

	puts
end

puts "Elapsed time: #{Time.now - start}"
