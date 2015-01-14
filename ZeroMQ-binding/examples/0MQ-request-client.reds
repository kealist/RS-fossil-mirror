Red/System [
	Title:		"ZeroMQ request/reply client example"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2014 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red/System >= 0.3.1
		%C-library/ANSI.reds
		%ZeroMQ-binding.reds
	}
	Tabs:		4
]


#include %../../C-library/ANSI.reds
#include %../ZeroMQ-binding.reds


with zmq [

	major: 0  minor: 0  patch: 0

	version :major :minor :patch
	print-line [
		"0MQ version: " major #"." minor #"." patch
		newline
	]


	; Hello World client/server

	log-error: does [  ; FIXME: should go to stderr
		print-line form-error system-error
	]

	client: function [
		/local pool socket count message request data size
	][
		pool: make-pool 1
		; For 0MQ <= 2.0.6:
;		pool: make-pool 1 1 0

		either none? pool [
			log-error
		][
			print-line "Connecting to Hello World server..."

			socket: open-socket pool request!

			either none? socket [
				log-error
			][
				either connect socket "tcp://localhost:5555" [
					message: declare message!

					request: "Hello"
					size: (length? request) + 1

					count: 0

					until [
						count: count + 1

						print-line ["Sending request " count]
						data: allocate size

						either none? data [
							print-line "Error: out of memory!"
						][
							either all [
								send socket message
									copy-part as-binary request  data size
									size
									zmq-none
								receive socket message zmq-none
							][
								data: message-data-of message

								either none? data [
									print-line "Error: no message content available"
								][
									; WARN: assume null tail marker is included
									print-line ["Received reply " count ": " as-c-string data]
								]
								unless end-message message [log-error]
							][
								log-error
							]
						]

						count = 10
					]
				][
					log-error
				]
				unless close-socket socket [log-error]
			]
			unless end-pool pool [log-error]
		]
	]

]

client
