Red [
	Title:		"ZeroMQ ventilator worker example"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2012-2014 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red >= 0.4.3
		%C-library/ANSI.red
		%ZeroMQ-binding.red
	}
	Tabs:		4
]

;#include %../../C-library/ANSI.red
#include %../ZeroMQ-binding.red

source-address:	any [get-argument 1  tcp://localhost:5557]
sink-address:	any [get-argument 2  tcp://localhost:5558]

log-error: does [  ; FIXME: should go to stderr
	print form-error system-error
]

print ["Worker:" system/platform system/version]

either zero? pool: make-pool 1 [
	log-error
][
	print ["Connecting to ventilator at" source-address]

	either zero? source: open-socket pool pull! [
		log-error
	][
		either all [
			connect source source-address
			(
				print ["Connecting to sink at" sink-address]
				not zero? sink: open-socket pool push!
			)
		][
			either connect sink sink-address [
				print "Pulling tasks from ventilator source..."

;				random/seed/secure 0
				work: ""
				task: 0

;				forever [
				while [yes] [
					unless all [
						receive/into source work
						(
							print ["Task" task: task + 1 ":" work]
							send sink  mold reduce [
								system/platform
								system/version
								probe do work
							]
						)
					][
						log-error
					]
				]
			][
				log-error
			]
			unless close-socket sink [log-error]
		][
			log-error
		]
		unless close-socket source [log-error]
	]
	unless end-pool pool [log-error]
]
