/*
	Mandelbrot fractal ASCII renderer
	Copyright (c) 2012 Kaj de Vos
	Adapted from Erik Wrenholt
		http://www.timestretch.com/article/mandelbrot_fractal_benchmark
	License: PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
*/

#include <stdio.h>
#include <time.h>

#define threshold		16.0
#define max_iterations	50000

int mandelbrot (
	double x,
	double y
){
	double cr = y - 0.5;
	double ci = x;
	double zr = 0.0, zi = 0.0;
	int i = 1;

	do {
		double value = zr * zi;
		double zr2 = zr * zr;
		double zi2 = zi * zi;
		zr = zr2 - zi2 + cr;
		zi = value + value + ci;

		if (zr2 + zi2 > threshold) return i;
	} while (++i <= max_iterations);

	return 0;
}

int main (int argc, const char * argv []) {
	time_t start = time (NULL);

	for (int y = -39; y <= 39; y++) {
		for (int x = -39; x <= 39; x++) {
			putchar (mandelbrot (x / 40.0, y / 40.0) == 0 ? '*' : ' ');
		}
		putchar ('\n');
	}

	printf ("Elapsed time: %f\nProcessor time: %f\n",
		difftime (time (NULL), start),
		(double) clock () / CLOCKS_PER_SEC
	);
}
