Red/System [
	Title:		"OSM GPS Map browser example"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011,2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red/System >= 0.3.1
		%OSM-GPS-Map.reds
	}
	Tabs:		4
]

#include %../OSM-GPS-Map.reds

with gtk [
	view [
		maximize
		"OSM GPS Map Browser"
		osm-gps-map ogm-new-osd
	]
]
