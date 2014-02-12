/*
	Fibonacci numbers
	Copyright (c) 2012 Kaj de Vos
	License: PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
*/

#include <stdio.h>
#include <time.h>

#define parameter 40

int fibonacci (int n) {
	return n < 2 ? n : fibonacci (n - 1) + fibonacci (n - 2);
}

int main (int argc, const char * argv []) {
	time_t start = time (NULL);
	int f = fibonacci (parameter);

	printf ("Fibonacci %i: %i\nElapsed time: %f\nProcess time: %f\n",
		parameter, f,
		difftime (time (NULL), start),
		(double) clock () / CLOCKS_PER_SEC
	);
}
