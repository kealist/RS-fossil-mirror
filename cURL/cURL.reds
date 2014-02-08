Red/System [
	Title:		"cURL Binding"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2010-2013 Kaj de Vos. All rights reserved."
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
		cURL >= 7.17
		%C-library/ANSI.reds
	}
	Notes: {
		For options copying.
		cURL >= 7.18 for transfer pausing.
		cURL >= 7.19.4 to interpret curl-ftp-create-dir-retry fully.
	}
	Tabs:		4
]


#include %../C-library/ANSI.reds


curl: context [

	; Error handling

	#enum status! [
		error-write:					23
		error-read:						26  ; 37?
	]


	#enum begin-mask! [
		global-nothing
		global-ssl:						00000001h
		global-win32:					00000002h
		global-all:						00000003h
		global-default:					global-all
	]


	#enum set-option! [
		set-verbose?:					41
		set-url:						10002
		set-upload?:					46
		set-in-file-size:				14

		set-write-data:					10001
		set-write-function:				20011

		set-read-data:					10009
		set-read-function:				20012

		set-progress-data:				10057
		set-progress-function:			20056
		set-seek-data:					168
		set-seek-function:				20167

		set-follow-location?:			52

		set-ftp-create-missing-dirs:	110

		set-http-auth:					107
		set-proxy-auth:					111
		set-ftp-ssl-auth:				129
		set-ssh-auth:					151
	]


	#enum read-option! [
		read-function-abort:			10000000h
		read-function-pause:			10000001h  ; cURL >= 7.18
	]

	#enum write-option! [
		write-function-pause:			10000001h  ; cURL >= 7.18
	]

	#enum ftp-option! [
		ftp-create-dir-retry:			2
	]


	#enum ssl-version! [
		ssl-version-default
		ssl-version-tls1
		ssl-version-ssl2
		ssl-version-ssl3
		ssl-version-last				; Marker, not a method
	]

	#enum authentication! [
		auth-none
		auth-basic:						00000001h		; Default
		auth-digest:					00000002h
		auth-gss-negotiate:				00000004h
		auth-ntlm:						00000008h
		auth-digest-IE:					00000010h
		auth-ntlm-winbind:				00000020h
		auth-any:						FFFFFFFFh		; NOT 0  ; Ask server
		auth-any-safe:					FFFFFFFEh		; NOT auth-basic
	]

	#enum ftp-auth! [
		ftp-auth-default				; Automatic
		ftp-auth-ssl
		ftp-auth-tls
		ftp-auth-last					; Marker, not a method
	]

	#enum ssh-auth! [
		ssh-auth-none									; Dummy
		ssh-auth-public-key:			00000001h
		ssh-auth-password:				00000002h
		ssh-auth-host:					00000004h
		ssh-auth-keyboard:				00000008h		; Interactive
		ssh-auth-any:					FFFFFFFFh		; NOT 0  ; Ask server
		ssh-auth-default:				ssh-auth-any
	]


	#switch OS [
		Windows		[#define cURL-library "libcurl.dll"]
		MacOSX		[#define cURL-library "libcurl.dylib"]  ; libcurl1.4.dylib, libcurl1.3.dylib
		#default	[#define cURL-library "libcurl.so.4"]
	]
	#import [cURL-library cdecl [
		version: "curl_version" [			"Return cURL version."
			return:		[c-string!]
		]


		; Error handling

		form-error: "curl_easy_strerror" [	"Return status message."
			code		[status!]
			return:		[c-string!]
		]


		; Global setup and teardown
		; WARN: not thread safe

		_begin: "curl_global_init" [		"Set up global cURL environment."
			flags		[begin-mask!]		"long!"
			return:		[status!]
		]
		_end: "curl_global_cleanup" [		"Clean up global cURL environment."
		]


		; Session management

		_make-session: "curl_easy_init" [	"Return session handle."
			return:		[handle!]
		]
		_end-session: "curl_easy_cleanup" [	"Clean up session."
			session		[handle!]
		]


		; Settings

		set: "curl_easy_setopt" [			"Set session option."
			session		[handle!]
			name		[set-option!]
			value		[variant!]
			return:		[status!]
		]
		clear: "curl_easy_reset" [			"Clear session settings."
			session		[handle!]
		]


		; Transfer

		_do: "curl_easy_perform" [			"Perform single prepared action on a URL."
			session		[handle!]
			return:		[status!]
		]


		; Events control

	]]


	session!: alias struct! [
		handle		[handle!]

		file		[file!]

		data		[binary!]
		size		[integer!]
		index		[integer!]  ; 0 based
	]


	; Global setup and teardown
	; WARN: not thread safe

	begin: function ["Set up global cURL environment."
		return:		[status!]
	][
		_begin global-all
	]
	end: function ["Clean up global cURL environment."
	][
		_end
	]


	; Session management

	make-session: function ["Return session handle."
		return:		[session!]
		/local		session
	][
		session: as session! allocate size? session!

		if as-logic session [  ; TODO?: report curl-error-out-of-memory
			session/handle: _make-session

			either none? session/handle [
				free-any session
				return null
			][
				; For safety
				session/data: null
				session/index: 0
			]
		]
		session
	]
	end-session: function ["Clean up session."
		session		[session!]
	][
		_end-session session/handle
		free-any session
	]


	; Transfer preparation

	store: function [[cdecl]
		"Store a received data buffer."
		buffer		[binary!]
		width		[size!]
		chunks		[size!]
		session		[session!]
		return:		[size!]
		/local size data index rest
	][
		index: session/index
		rest: session/size - index
		size: chunks * width

		if size > rest [  ; Need to expand data storage
			data: resize session/data  index + size

			either none? data [
				size: rest
			][	; Expansion succeeded
				session/data: data
				session/size: index + size
			]
		]
		copy-part buffer  session/data + index  size
		session/index: index + size

		size
	]
	get: function ["Prepare receive action."
		session		[session!]
		buffer		[binary!]
		size		[integer!]
		return:		[status!]
		/local handle status
	][
		handle: session/handle

		session/file: null
		session/data: buffer
		session/size: size
		session/index: 0

		status: set handle set-write-data  as variant! session

		if zero? status [
			status: set handle set-upload?  as variant! no

			if zero? status [
				status: set handle set-ftp-create-missing-dirs  as variant! no

				if zero? status [
					status: set handle set-write-function  as variant! :store
				]
			]
		]
		status
	]

	fetch: function [[cdecl]
		"Fill data buffer to be sent."
		buffer		[binary!]
		width		[size!]
		chunks		[size!]
		session		[session!]
		return:		[size!]
		/local size index rest
	][
		index: session/index
		rest: session/size - index

		size: chunks * width
		if size > rest [size: rest]

		copy-part session/data + index  buffer size
		session/index: index + size

		size
	]
	put: function ["Prepare send action."
		session		[session!]
		data		[handle!]  "binary! or file! (WARNING: file! only if libcurl is not a Win32 DLL)"
		size		[integer!]  "-1: unknown"
		return:		[status!]
		/local handle status
	][
		handle: session/handle

		session/file: null
		session/data: as-binary data
;		session/size: size
		session/index: 0

		status: set handle set-read-data  as variant! session

		if zero? status [
			status: set handle set-upload?  as variant! yes

			if zero? status [
				status: set handle set-in-file-size size

				if zero? status [
					status: set handle set-ftp-create-missing-dirs ftp-create-dir-retry

					if zero? status [
						status: set handle set-read-function  as variant! :fetch
					]
				]
			]
		]
		status
	]

	; WARN: don't work if libcurl is a Win32 DLL

	get-file: function ["Prepare receiving file."
		session		[session!]
		name		[c-string!]
		return:		[status!]
		/local handle file status
	][
		handle: session/handle
		status: set handle set-write-function null

		if zero? status [
			status: set handle set-upload?  as variant! no

			if zero? status [
				status: set handle set-ftp-create-missing-dirs  as variant! no

				if zero? status [
					file: open-new name

					status: either none? file [  ; Would segfault without this check
						error-write  ; TODO: report real file error
					][
						session/file: file
						set handle set-write-data  as variant! file
					]
				]
			]
		]
		status
	]
	put-file: function ["Prepare sending file."
		session		[session!]
		name		[c-string!]
		return:		[status!]
		/local handle file status
	][
		handle: session/handle
		status: set handle set-read-function null

		if zero? status [
			status: set handle set-upload?  as variant! yes

			if zero? status [
				status: set handle set-ftp-create-missing-dirs ftp-create-dir-retry

				if zero? status [
					status: set handle set-in-file-size -1  ; TODO: get file size

					if zero? status [
						file: open-read name

						status: either none? file [  ; Would segfault without this check
							error-read  ; TODO: report real file error
						][
							session/file: file
							set handle set-read-data  as variant! file
						]
					]
				]
			]
		]
		status
	]


	; Transfer

	do: function ["Perform single prepared action on a URL."
		session		[session!]
		target		[c-string!]
		return:		[status!]
		/local		status
	][
		status: set session/handle set-url  as variant! target

		if zero? status [
			status: _do session/handle
		]
		either any [none? session/file  close session/file] [
			status
		][
			error-read  ; TODO: report real file error
		]
	]


	; Global setup

	status: begin

	either zero? status [
		on-quit as-integer :end
	][
		print-line [
			"Error setting up cURL networking:" newline
			form-error status
		]
	]

]


; Higher level interface


with curl [

	read-url: function ["Read text file from network."
		url			[c-string!]
		return:		[c-string!]
		/local
			text	[binary!]
			session size
	][
		text: null

		if as-logic url [
			session: make-session

			if as-logic session [
				if zero? set session/handle set-follow-location?  as variant! yes [
					; Size of initial data buffer. It will be resized when needed.
					size: 10'000
					text: allocate size

					if as-logic text [
						either any [
							as-logic get session text size
							as-logic do session url
						][
							free text
							text: null
						][
							; Make it a string by appending a null byte

							size: session/index + 1
							text: resize session/data size

							either none? text [
								free session/data
							][
								text/size: null-byte
							]
						]
					]
				]
				end-session session
			]
		]
		as-c-string text
	]

	write-url: function ["Write text to a network file."
		url			[c-string!]
		text		[c-string!]
		return:		[logic!]
		/local session ok?
	][
		either any [none? url  none? text] [
			no
		][
			session: make-session

			either none? session [
				no
			][
				ok?: all [
					zero? put session  as-handle text  length? text
					zero? do session url
				]
				end-session session

				ok?
			]
		]
	]

]
