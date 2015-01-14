Red [
	Title:		"ZeroMQ ventilator sink example"
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

address: any [get-argument 1  tcp://*:5558]

log-error: does [  ; FIXME: should go to stderr
	print form-error system-error
]

either zero? pool: make-pool 1 [
	log-error
][
	print ["Setting up ventilator sink server on" address]

	either zero? sink: open-socket pool pull! [
		log-error
	][
		either all [
			serve sink address
			(
				print "Awaiting start of batch..."
				dummy: receive sink  ; Signal message: discard
			)
			end-message dummy
		][
			time: now/precise
			print "Pulling processed tasks from workers..."

			message: ""
			total: 0

			loop 100 [
				either receive/into sink message [
					set [platform version result] probe load message

					if integer? result [total: total + result]
				][
					log-error
				]
			]
			print [
				"Result total:" total  newline
				"Elapsed seconds:" subtract-time now/precise time
			]
		][
			log-error
		]
		unless close-socket sink [log-error]
	]
	unless end-pool pool [log-error]
]
