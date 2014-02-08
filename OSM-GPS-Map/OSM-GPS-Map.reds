Red/System [
	Title:		"OSM GPS Map Binding"
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
		Red/System > 0.3.2
		OSM-GPS-Map
	}
	Tabs:		4
]


#include %../GTK/GTK.reds


; Map views

ogm-view!:		alias opaque!


; Layers

ogm-layer!:		alias opaque!
ogm-osd!:		alias opaque!


#switch OS [
	Windows		[#define OSM-GPS-Map-library "libosmgpsmap-2.dll"]  ; TODO: check this
	MacOSX		[#define OSM-GPS-Map-library "libosmgpsmap.dylib"]  ; TODO: check this
	#default	[#define OSM-GPS-Map-library "libosmgpsmap.so.2"]  ; Ubuntu 10.10
]
#import [OSM-GPS-Map-library cdecl [
	; Map views

	ogm-new-view: "osm_gps_map_new" [			"Return new OSM GPS Map view."
		return:			[ogm-view!]
	]
	ogm-add-layer: "osm_gps_map_layer_add" [	"Add layer to OSM GPS Map."
		view			[ogm-view!]
		layer			[ogm-layer!]
	]


	; OSD layer

	ogm-new-osd: "osm_gps_map_osd_new" [		"Return new OSD layer."
		return:			[ogm-osd!]
	]
]]


; Dialect constructors


with gtk [
	osm-gps-map: function ["Build an OSM GPS Map widget."
		[typed]
		count				[integer!]
		list				[typed-value!]
		return:				[ogm-view!]
		/local				view
	][
		view: ogm-new-view

		either as-logic view [
			while [as-logic count] [
				either any-struct? list/type [
					either as-logic list/value [
						ogm-add-layer view  as ogm-layer! list/value
					][
						log-error "OSM GPS Map: skipping missing layer."
					]
				][
					log-error "OSM GPS Map: skipping unknown element."
				]
				count: count - 1
				list: list + 1
			]
		][
			log-error "Failed to create OSM GPS Map view."
		]
		view
	]
]
