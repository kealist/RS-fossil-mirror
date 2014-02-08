Red/System [
	Title:		"Java Native Interface library example"
	Type:		'library
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red/System
		%Java/JNI-library.reds
	}
	Purpose: {
		This is a simple example of a native library for Java through the JNI interface,
		written in Red/System.
	}
	Tabs:		4
]


#define do-on-load (vm java-reference java) [
	version: java/version-of java-reference  ; WARN: variable will be global
	print [
		"Hello from JNI!" newline
		"JNI version: "  version >>> 16  #"."  version and FFFFh  newline
	]
]

#include %../JNI-library.reds


with JNI [
	JNI_OnUnload: function [
		vm-reference					[vm-reference!]
		dummy							[handle!]
	][
		print-line "Goodbye JNI!"
	]
]

#export call! [JNI_OnUnload]
