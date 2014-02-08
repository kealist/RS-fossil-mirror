Red/System [
	Title:		"WebKitGTK+ Binding"
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
		WebKitGTK+
	}
	Tabs:		4
]


#include %../GTK/GTK.reds


; Web views

web-view!:				alias opaque!


#switch OS [
	Windows		[#define GTK-WebKit-library "libwebkit-win32-1.0-2.dll"]  ; TODO: check this
	MacOSX		[#define GTK-WebKit-library "libwebkit-x11-1.0.dylib"]  ; TODO: check this
	#default	[#define GTK-WebKit-library "libwebkit-1.0.so.2"]  ; Old WebKit
]
#import [GTK-WebKit-library cdecl [
	; Web views

	web-new-view: "webkit_web_view_new" [		"Return new web view widget."
		return:			[web-view!]
	]

	web-browse: "webkit_web_view_load_uri" [	"Load URI in web view."
		view			[web-view!]
		uri				[c-string!]
	]
]]


; Higher level interface


with gtk [

	web-get-view: function ["Get web view from BROWSE widget."
		browser				[scrolled-window!]
		return:				[web-view!]
		/local				list
	][
		list: get-container-children as container! browser

		either as-logic list [
			as web-view! list/data
		][
			null
		]
	]


	; Dialect constructors


	browse: function ["Build a web view."
		[typed]
		count				[integer!]
		list				[typed-value!]
		return:				[scrolled-window!]
		/local				view
	][
		view: web-new-view

		either as-logic view [
			while [as-logic count] [
				either list/type = type-c-string! [
					either as-logic list/value [
						web-browse view  as-c-string list/value
					][
						log-error "Web view: skipping missing URI."
					]
				][
					log-error "Web view: skipping unknown element."
				]
				count: count - 1
				list: list + 1
			]
		][
			log-error "Failed to create web view."
		]
		scroll view
	]

]
