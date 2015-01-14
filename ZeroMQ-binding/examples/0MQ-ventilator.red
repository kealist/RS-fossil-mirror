Red [
	Title:		"ZeroMQ ventilator source example"
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

#include %../../C-library/ANSI.red
#include %../ZeroMQ-binding.red

work:			any [get-argument 1  "random 100"]
source-address:	any [get-argument 2  tcp://*:5557]
sink-address:	any [get-argument 3  tcp://localhost:5558]

log-error: does [  ; FIXME: should go to stderr
	print form-error system-error
]

either zero? pool: make-pool 1 [
	log-error
][
	print ["Setting up ventilator server on" source-address]

	either zero? source: open-socket pool push! [
		log-error
	][
		either all [
			serve source source-address
			(
				print ["Connecting to sink at" sink-address]
				not zero? sink: open-socket pool push!
			)
		][
			either all [
				connect sink sink-address
				(
					ask "Press Enter when the workers and sink are ready: "
					send sink none  ; Start of batch
				)
			][
				print "Pushing tasks to workers..."

				repeat task 100 [
					print ["Pushing task" task]

					unless send source work [log-error]
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
