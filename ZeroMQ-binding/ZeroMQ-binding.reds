Red/System [
	Title:		"ZeroMQ Binding"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2014 Kaj de Vos. All rights reserved."
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
		Red/System >= 0.3.3
		0MQ >= 2.0.7
		; For Windows:
		0MQ >= 3
		%common.reds
	}
	Tabs:		4
]


#include %../common/common.reds


zmq: context [

	; System interface

	#enum status! [
		error-again:		11  ; EAGAIN: Linux, Windows; TODO: check for other platforms
	]


	; 0MQ interface

	#enum socket-type! [
		pair!
		publish!
		subscribe!
		request!
		reply!
		dealer!
		router!
		pull!
		push!
;		For 0MQ >= 4:
		stream!:			11
	]

	#enum socket-option! [
		max-messages:		1
		min-messages		; Not always available
		swap-size
		io-affinity
		identity
		filter
		unsubscribe
		max-rate
		recovery-interval
		loop-back?
		send-buffer
		receive-buffer
		receive-more?
		linger:				17
;		For 0MQ >= 2.2
		receive-timeout:	27
		send-timeout
	]

	#enum send-receive-flags! [
		zmq-none
		no-wait
		send-more
	]

	#enum wait-mask! [
		poll-in:			1
		poll-out:			2
		poll-error:			4
	]


	pool!:					alias opaque!
	socket!:				alias opaque!

	message!: alias struct! [
		content				[handle!]
		flags				[byte!]
		size				[byte!]
		data				[integer32!]  ; unsigned char [ZMQ_MAX_VSM_SIZE] (default 30)
		data2				[integer64!]
		data3				[integer64!]
		data4				[integer64!]
		data5				[integer16!]
	]

	#switch OS [
		Windows		[#define ZMQ-library "libzmq.dll"]
		MacOSX		[#define ZMQ-library "libzmq.dylib"]
		#default	[#define ZMQ-library "libzmq.so.1"]
	]
	#import [ZMQ-library cdecl [
		version: "zmq_version" [				"Return 0MQ version."
			major		[pointer! [integer!]]
			minor		[pointer! [integer!]]
			patch		[pointer! [integer!]]
		]


		; Error handling

		system-error: "zmq_errno" [				"Return last status."
			return: 	[status!]
		]
		form-error: "zmq_strerror" [			"Return status message."
			code		[status!]
			return:		[c-string!]
		]


		; Pool context management

		make-pool: "zmq_init" [					"Return new context handle."
;			app-threads	[integer!]  ; For 0MQ <= 2.0.6
			io-threads	[integer!]
;			flags		[integer!]  ; For 0MQ <= 2.0.6
			return: 	[pool!]
		]
		_end-pool: "zmq_term" [					"Clean up context."
			pool		[pool!]
			return: 	[status!]
		]

		open-socket: "zmq_socket" [				"Return a new socket."
			pool		[pool!]
			type		[socket-type!]
			return: 	[socket!]
		]
		_close: "zmq_close" [					"Clean up socket from context."
			socket		[socket!]
			return: 	[status!]
		]


		; Socket and connection management

		_set: "zmq_setsockopt" [				"Set socket option."
			socket		[socket!]
			name		[socket-option!]
			value		[handle!]
			size		[size!]
			return: 	[status!]
		]
		; For 0MQ > 2.0.6:
		_get: "zmq_getsockopt" [				"Get socket option."
			socket		[socket!]
			name		[socket-option!]
			value		[handle!]				"Currently max 255 bytes"
			size		[pointer! [size!]]
			return: 	[status!]
		]

		_serve: "zmq_bind" [					"Set up server socket binding."
			socket		[socket!]
			end-point	[c-string!]
			return: 	[status!]
		]
		_connect: "zmq_connect" [				"Connect to a server socket."
			socket		[socket!]
			destination	[c-string!]
			return: 	[status!]
		]


		; Message management and transfer

		_make-message: "zmq_msg_init_size" [	"Create a new message."
			message		[message!]
			size		[size!]
			return: 	[status!]
		]
		_clear-message: "zmq_msg_init" [		"Set up a new empty message."
			message		[message!]
			return: 	[status!]
		]
		_as-message: "zmq_msg_init_data" [		"Convert to a new message."
			message		[message!]
			data		[binary!]
			size		[size!]
			free		[function! [data [binary!] hint [handle!]]]
			hint		[handle!]
			return: 	[status!]
		]
		_end-message: "zmq_msg_close" [			"Clean up message."
			message		[message!]
			return: 	[status!]
		]

		message-data-of: "zmq_msg_data" [		"Return message data pointer."
			message		[message!]
			return:		[binary!]
		]
		message-size-of: "zmq_msg_size" [		"Return message data size."
			message		[message!]
			return: 	[size!]
		]

		#either OS = 'Windows [  ; 0MQ >= 3
			_send-message: "zmq_msg_send" [		"Send message."
				message		[message!]
				socket		[socket!]
				flags		[send-receive-flags!]
				return: 	[status!]
			]
			_receive-message: "zmq_msg_recv" [	"Receive a message."
				message		[message!]
				socket		[socket!]
				flags		[send-receive-flags!]
				return: 	[status!]
			]

			more-message?: "zmq_msg_more" [		"Is message followed by more parts in a multi-part message?"
				message		[message!]
				return: 	[logic!]
			]
		][
			_send-message: "zmq_send" [			"Send message."
				socket		[socket!]
				message		[message!]
				flags		[send-receive-flags!]
				return: 	[status!]
			]
			_receive-message: "zmq_recv" [		"Receive a message."
				socket		[socket!]
				message		[message!]
				flags		[send-receive-flags!]
				return: 	[status!]
			]
		]

		_copy-message: "zmq_msg_copy" [			"Copy message content to another message."
			target		[message!]
			source		[message!]
			return: 	[status!]
		]
		_move-message: "zmq_msg_move" [			"Move message content to another message."
			target		[message!]
			source		[message!]
			return: 	[status!]
		]


		; Events control

		wait: "zmq_poll" [						"Wait for selected events or timeout."
			events		[handle!]
			length		[integer!]
			timeout		[long!]
			return: 	[integer!]				"Events signaled or -1"
		]
	]]


	; Higher level interface


	; Pool context management

	end-pool: function ["Clean up context."
		pool		[pool!]
		return:		[logic!]
	][
		not as-logic _end-pool pool
	]
	close-socket: function ["Clean up socket from context."
		socket		[socket!]
		return:		[logic!]
	][
		not as-logic _close socket
	]


	; Socket options

	set: function ["Set socket option."
		socket		[socket!]
		name		[socket-option!]
		value		[handle!]
		size		[size!]
		return:		[logic!]
	][
		not as-logic _set socket name value size
	]

	; For 0MQ > 2.0.6
	get: function ["Get socket option."
		socket		[socket!]
		name		[socket-option!]
		value		[handle!]  "Currently max 255 bytes"
		size		[pointer! [size!]]
		return:		[logic!]
	][
		not as-logic _get socket name value size
	]
	get-integer: function ["Get integer socket option."
		socket		[socket!]
		name		[socket-option!]
		value		[pointer! [integer!]]
		return:		[logic!]
		/local integer64 size
	][
		integer64: declare integer64-reference!  ; WARN: not thread safe
		size: 8

		either all [
			get socket name  as-handle integer64  :size
			size = 8
		][
			value/value: integer64/low
			yes
		][
			no
		]
	]
	get-logic: function ["Get logic! socket option."
		socket		[socket!]
		name		[socket-option!]
		value		[pointer! [integer!]]
		return:		[logic!]
		/local		size
	][
		#either OS = 'Windows [  ; 0MQ >= 3
			size: 4
			all [
				get socket name  as-handle value  :size
				size = 4
			]
		][
			get-integer socket name value
		]
	]


	; Connection management

	serve: function ["Set up server socket binding."
		socket		[socket!]
		end-point	[c-string!]
		return:		[logic!]
	][
		not as-logic _serve socket end-point
	]
	connect: function ["Connect to a server socket."
		socket		[socket!]
		destination	[c-string!]
		return:		[logic!]
	][
		not as-logic _connect socket destination
	]


	; Message management

	make-message: function ["Create a new message."
		message		[message!]
		size		[size!]
		return:		[logic!]
	][
		not as-logic _make-message message size
	]
	clear-message: function ["Set up a new empty message."
		message		[message!]
		return:		[logic!]
	][
		not as-logic _clear-message message
	]
	as-message: function ["Convert to new message."
		message		[message!]
		data		[binary!]
		size		[size!]
;;		free		[function! [data [binary!] hint [handle!]]]
;		free		[handle!]
;		hint		[handle!]
		return:		[logic!]
	][
		not as-logic _as-message message data size null null
	]
	end-message: function ["Clean up message."
		message		[message!]
		return:		[logic!]
	][
		not as-logic _end-message message
	]

	copy-message: function ["Copy message content to another message."
		source		[message!]
		target		[message!]
		return:		[logic!]
	][
		not as-logic _copy-message target source
	]
	move-message: function ["Move message content to another message."
		source		[message!]
		target		[message!]
		return:		[logic!]
	][
		not as-logic _move-message target source
	]

	empty-message?: function ["Is message empty?"
		message		[message!]
		return:		[logic!]
	][
		zero? message-size-of message
	]

	free-message: function ["Free data buffer."
		[cdecl]
		data		[binary!]
		hint		[handle!]
	][
		free data
	]


	; Message transfer

	empty-socket?: function ["Are no incoming messages available? WARNING: only valid immediately after a receive error."
		return:		[logic!]
	][
		system-error = error-again
	]

	message-tail?: function ["Was last message the last part of a possibly multi-part message?"
		socket		[socket!]
;		message		[message!]
		return:		[integer!]  "1: complete; 0: more parts; -1: error"
		/local		value
	][
;		#either 0MQ >= 3 [
;			as-integer not more-message? message
;		][
			value: 0

			either get-logic socket receive-more? :value [
				value xor 1
			][
				-1
			]
;		]
	]

	send-message: function ["Send message."
		socket		[socket!]
		message		[message!]
		flags		[send-receive-flags!]
		return:		[logic!]
	][
		0 <= _send-message #either OS = 'Windows [message socket] [socket message] flags
	]
	receive-message: function ["Receive a message."
		socket		[socket!]
		message		[message!]
		flags		[send-receive-flags!]
		return:		[logic!]
	][
		0 <= _receive-message #either OS = 'Windows [message socket] [socket message] flags
	]

	send-empty: function ["Send empty message."
		socket		[socket!]
		message		[message!]
		flags		[send-receive-flags!]
		return:		[logic!]
	][
		all [
			make-message message 0
			either send-message socket message flags [
				not as-logic _end-message message
			][
				_end-message message  ; FIXME: error code may get replaced
				no
			]
		]
	]

	send: function ["Send message, then free payload data."
		socket		[socket!]
		message		[message!]  ; TODO: make local on stack
		data		[binary!]
		size		[integer!]
		flags		[send-receive-flags!]
;		recycle		[function! [data [binary!] hint [handle!]]]
;		recycle		[handle!]
		return:		[logic!]
	][
		either as-logic _as-message message data size :free-message null [
			free data
			no
		][
			either send-message socket message flags [
				not as-logic _end-message message
			][
				_end-message message  ; FIXME: error code may get replaced
				no
			]
		]
	]
	receive: function ["Receive a message."
		socket		[socket!]
		message		[message!]
		flags		[send-receive-flags!]
		return:		[logic!]
	][
		all [
			clear-message message
			either receive-message socket message flags [
				yes
			][
				_end-message message  ; FIXME: error code may get replaced
				no
			]
		]
	]

]
