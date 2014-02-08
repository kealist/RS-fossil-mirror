Red/System [
	Title:		"GDK Binding"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2013 Kaj de Vos. All rights reserved."
	License: {
		Redistribution and use in source and binary forms, with or without modification,
		are permitted provided that the following conditions are met:

		    * Redistributions of source code must retain the above copyright notice,
		      this list of conditions and the following disclaimer.
		    * Redistributions in binary form must reproduce the above copyright notice,
		      this list of conditions and the following disclaimer in the documentation
		      and/or other materials provided with the distribution.

		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
		ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
		WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
		DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
		FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
		DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
		SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
		CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
		OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
		OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	}
	Needs: {
		Red/System >= 0.3.2
		GDK
		%GLib.reds
	}
	Tabs:		4
]


#include %../GLib/GLib.reds


with g [gdk: context [

	gdk-window!:						alias opaque!

	image!: alias struct! [
	;	parent							[g-object!]
			class						[g-type-class!]
			reference-count				[unsigned!]
	;		data						[g-data!]  ; TODO

	;	... TODO
	]

	rectangle!: alias struct! [
		x								[integer!]
		y								[integer!]
		width							[integer!]
		height							[integer!]
	]


	#switch OS [
		Windows		[#define GDK-library "libgdk-win32-2.0-0.dll"]
		MacOSX		[#define GDK-library "libgdk-x11-2.0.dylib"]  ; TODO: check this
		#default	[#define GDK-library "libgdk-x11-2.0.so.0"]
	]
	#import [GDK-library cdecl [
		image-type: "gdk_image_get_type" [				"Image type."
			return:				[g-type!]
		]
	]]


	#switch OS [
		Windows		[#define GDK-pixbuf-library "libgdk_pixbuf-2.0-0.dll"]
		MacOSX		[#define GDK-pixbuf-library "libgdk_pixbuf-2.0.dylib"]  ; TODO: check this
		#default	[#define GDK-pixbuf-library "libgdk_pixbuf-2.0.so.0"]
	]
	#import [GDK-pixbuf-library cdecl [
		load-image: "gdk_pixbuf_new_from_file" [		"Load image file."
			file				[c-string!]
			error				[g-error-reference!]
			return:				[image!]
		]
	]]


	; Higher level interface


;	WARN: doesn't work at least in GTK 2.18.5
	gdk-image?: function ["Test for GDK image type."
		instance			[g-object!]
		return:				[logic!]
	][
		any [
			all [as-logic instance/class  instance/class/type = image-type]
			as-logic check-instance-type  as g-type-instance! instance  image-type
		]
	]

]]
