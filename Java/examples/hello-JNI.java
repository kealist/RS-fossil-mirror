/*
	Java Native Interface example

	Copyright (c) 2013 Nenad Rakocevic, Kaj de Vos
	License: PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/

	Needs 32-bit Java.

	This is a minimal Java launcher program for an example
	of a native library for Java through the JNI interface.
*/

class helloJNI {
	static {
		System.loadLibrary ("hello-JNI");
	}

	public static void main (String [] args) {
	}
}
