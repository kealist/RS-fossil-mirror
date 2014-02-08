Red [
	Title:		"ZeroMQ request/reply client example"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red >= 0.3.3
		%ZeroMQ-binding.red
	}
	Tabs:		4
]


#include %../ZeroMQ-binding.red


prin ["0MQ version:" major-version]
	prin #"."  prin minor-version
	prin #"."  print patch-version
print ""


; Hello World client/server

address: any [get-argument 1  "tcp://localhost:5555"]
request: "Hello"

log-error: does [  ; FIXME: should go to stderr
	print form-error system-error
]

client: function [] [
	either zero? pool: make-pool 1 [
		log-error
	][
		print ["Connecting to Hello World server at" address]

		either zero? socket: open-socket pool request! [
			log-error
		][
			either connect socket address [
				data: ""

				repeat count 10 [
					print ["Sending request" count]

					either all [
						send socket request
						receive/into socket data
					][
						prin ["Received reply" count] print [":" data]
					][
						log-error
					]
				]
			][
				log-error
			]
			unless close-socket socket [log-error]
		]
		unless end-pool pool [log-error]
	]
]

client
