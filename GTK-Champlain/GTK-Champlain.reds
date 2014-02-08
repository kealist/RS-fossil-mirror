Red/System [
	Title:		"Champlain GTK+ Binding"
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
		Champlain-GTK
	}
	Tabs:		4
]


#include %../GTK/GTK.reds


#switch OS [
	Windows		[#define Clutter-GTK-library "libclutter-gtk-0.10-0.dll"]  ; TODO: check this
	MacOSX		[#define Clutter-GTK-library "libclutter-gtk-0.10.dylib"]  ; TODO: check this
	#default	[#define Clutter-GTK-library "libclutter-gtk-0.10.so.0"]  ; Ubuntu 10.10
]
#import [Clutter-GTK-library cdecl [
	; Global setup

	begin-clutter-gtk: "gtk_clutter_init" [			"Set up Clutter GTK+ library."
		argc-reference		[pointer! [integer!]]
		argv-reference		[handle-reference!]		"Triple reference!"
	]
]]


; Map views

champlain-view!: alias opaque!


#switch OS [
	Windows		[#define Champlain-GTK-library "libchamplain-gtk-0.4-0.dll"]  ; TODO: check this
	MacOSX		[#define Champlain-GTK-library "libchamplain-gtk-0.4.dylib"]  ; TODO: check this
	#default	[#define Champlain-GTK-library "libchamplain-gtk-0.4.so.0"]  ; Ubuntu 10.10
]
#import [Champlain-GTK-library cdecl [
	; Map views

	champlain-new-view: "gtk_champlain_embed_new" [	"Return new Champlain map view."
		return:				[champlain-view!]
	]
]]


; Dialect constructors


champlain-map: function ["Build a Champlain map widget."
;	[typed]
;	count				[integer!]
;	list				[typed-value!]
	return:				[champlain-view!]
	/local				view
][
	view: champlain-new-view

	unless as-logic view [
		gtk/log-error "Failed to create Champlain map view."
	]
	view
]


; Global setup

begin-clutter-gtk :argc argv-reference  ; Set up Clutter GTK+ library
