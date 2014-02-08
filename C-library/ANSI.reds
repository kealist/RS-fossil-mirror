Red/System [
	Title:		"ANSI C Library Binding"
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
		Red/System >= 0.4
		%common/FPU-configuration.reds
	}
	Tabs:		4
]


#include %../common/FPU-configuration.reds


; C types

#define time!					long!
#define clock!					long!

date!: alias struct! [
	second						[integer!]  ; 0-61 (60?)
	minute						[integer!]  ; 0-59
	hour						[integer!]  ; 0-23

	day							[integer!]  ; 1-31
	month						[integer!]  ; 0-11
	year						[integer!]  ; Since 1900

	weekday						[integer!]  ; 0-6 since Sunday
	yearday						[integer!]  ; 0-365
	daylight-saving-time?		[integer!]  ; Negative: unknown
]

#either OS = 'Windows [
	#define clocks-per-second	1000
][
	; CLOCKS_PER_SEC value for Syllable, Linux (XSI-conformant systems)
	; TODO: check for other systems
	#define clocks-per-second	1000'000
]


; C library

; file-at (fseek) origin codes for Syllable, Linux
; TODO: check for other systems
#enum seek-origin! [
	seek-set
	seek-current
	seek-end
]

; file-buffer (setvbuf) modes for Syllable, Linux
; TODO: check for other systems
#enum io-buffering! [
	io-full-buffering
	io-line-buffering
	io-no-buffering
]

; random (rand) maximum value RAND_MAX for GNU (Syllable, Linux)
; TODO: check for other systems
#define max-random				2147483647  ; 32 bits signed

; on-signal/signal (signal/raise) codes for Syllable, Linux
; TODO: check for other systems

#enum signal! [
	signal-default
	signal-ignore

	signal-hangup:				1
	signal-interrupt
;	signal-hold:				2  ; Unix 98
	signal-quit
	signal-illegal
	signal-trap
	signal-abort				; SIGABRT
	signal-bus-error
	signal-float-error
	signal-kill
	signal-user-1
	signal-seg-fault
	signal-user-2
	signal-broken-pipe
	signal-alarm-clock
	signal-terminate
	signal-stack-fault
	signal-child-status
	signal-continue
	signal-stop
	signal-tty-stop
	signal-tty-input
	signal-tty-output
	signal-urgent
	signal-cpu-limit
	signal-file-size
	signal-virtual-alarm
	signal-profiling
	signal-window-size
	signal-poll-event
	signal-power
	signal-system-call

	signal-max:					64
	signal-error:				-1  ; SIG_ERR
]

#import [LIBC-file cdecl [

	; Error handling

	form-error: "strerror" [				"Return error description."
		code			[integer!]
		return:			[c-string!]
	]
	print-error: "perror" [					"Print error to standard error output."
		string			[c-string!]
	]


	; Memory management

	make: "calloc" [						"Allocate and return zero-filled memory."
		chunks			[size!]
		size			[size!]
		return:			[binary!]
	]
	resize: "realloc" [						"Resize and return allocated memory."
		memory			[binary!]
		size			[size!]
		return:			[binary!]
	]


	; Memory block processing

	set-part: "memset" [					"Fill and return memory range."
		target			[binary!]
		filler			[byte!]				"integer!"
		size			[size!]
		return:			[binary!]
	]
	_copy-part: "memcpy" [					"Copy memory range, return target."
		target			[binary!]
		source			[binary!]
		size			[size!]
		return:			[binary!]
	]
	_move-part: "memmove" [					"Copy possibly overlapping memory range, return target."
		target			[binary!]
		source			[binary!]
		size			[size!]
		return:			[binary!]
	]

	compare-part: "memcmp" [				"Return comparison of memory range."
		part-1			[binary!]
		part-2			[binary!]
		size			[size!]
		return:			[integer!]
	]
	find-byte: "memchr" [					"Search for byte in memory range."
		memory			[binary!]
		byte			[byte!]				"integer!"
		size			[size!]
		return:			[binary!]
	]


	; Array processing

	sort: "qsort" [							"Sort array."
		array			[handle!]
		entries			[size!]
		size			[size!]
		comparator		[function! [entry-1 [handle!] entry-2 [handle!] return: [integer!]]]
	]

	find-sorted: "bsearch" [				"Search for entry in sorted array."
		key				[handle!]
		array			[handle!]
		entries			[size!]
		size			[size!]
		comparator		[function! [key [handle!] entry [handle!] return: [integer!]]]
		return:			[handle!]
	]


	; Character processing

	is-control: "iscntrl" [					"Test for control character."
		byte			[integer!]			"byte! or EOF"
		return:			[integer!]
	]
	is-printable: "isprint" [				"Test character for printability."
		byte			[integer!]			"byte! or EOF"
		return:			[integer!]
	]
	is-graphical: "isgraph" [				"Test character for displayability: printable and not whitespace."
		byte			[integer!]			"byte! or EOF"
		return:			[integer!]
	]
	is-punctuation: "ispunct" [				"Test character for punctuation."
		byte			[integer!]			"byte! or EOF"
		return:			[integer!]
	]
	is-blank: "isspace" [					"Test character for whitespace."
		byte			[integer!]			"byte! or EOF"
		return:			[integer!]
	]
	is-alphanumeric: "isalnum" [			"Test character for alphanumeric."
		byte			[integer!]			"byte! or EOF"
		return:			[integer!]
	]
	is-alphabetic: "isalpha" [				"Test character for alphabetic."
		byte			[integer!]			"byte! or EOF"
		return:			[integer!]
	]
	is-digit: "isdigit" [					"Test character for digit."
		byte			[integer!]			"byte! or EOF"
		return:			[integer!]
	]
	is-hex: "isxdigit" [					"Test character for hexadecimal digit."
		byte			[integer!]			"byte! or EOF"
		return:			[integer!]
	]
	is-uppercase: "isupper" [				"Test character for uppercase."
		byte			[integer!]			"byte! or EOF"
		return:			[integer!]
	]
	is-lowercase: "islower" [				"Test character for lowercase."
		byte			[integer!]			"byte! or EOF"
		return:			[integer!]
	]

	to-uppercase: "toupper" [				"Convert character to uppercase."
		byte			[integer!]			"byte!"
		return:			[integer!]			"byte!"
	]
	to-lowercase: "tolower" [				"Convert character to lowercase."
		byte			[integer!]			"byte!"
		return:			[integer!]			"byte!"
	]


	; String processing

	_copy-string: "strcpy" [				"Copy string including tail marker, return target."
		target			[c-string!]
		source			[c-string!]
		return:			[c-string!]
	]
	_copy-string-part: "strncpy" [			"Copy string range, return target."
		target			[c-string!]
		source			[c-string!]
		size			[size!]
		return:			[c-string!]
	]
	append-string: "strcat" [				"Append string, return target."
		target			[c-string!]
		source			[c-string!]
		return:			[c-string!]
	]
	append-string-part: "strncat" [			"Append string range, return target."
		target			[c-string!]
		source			[c-string!]
		size			[size!]
		return:			[c-string!]
	]

	compare-string: "strcmp" [				"Return string comparison."
		string-1		[c-string!]
		string-2		[c-string!]
		return:			[integer!]
	]
	compare-string-part: "strncmp" [		"Return comparison of string range."
		string-1		[c-string!]
		string-2		[c-string!]
		size			[size!]
		return:			[integer!]
	]

	find-char: "strchr" [					"Search for byte in string."
		string			[c-string!]
		byte			[byte!]				"integer!"
		return:			[c-string!]
	]
	find-last-char: "strrchr" [				"Search for byte in string from tail."
		string			[c-string!]
		byte			[byte!]				"integer!"
		return:			[c-string!]
	]
	find-string: "strstr" [					"Search for sub-string."
		string			[c-string!]
		substring		[c-string!]
		return:			[c-string!]
	]

	format-any: "sprintf" [					"Format arguments as string."
		[variadic]
		; string		[c-string!]			"WARNING: must be big enough!"
		; format		[c-string!]
		;	value		[variant!]
		;	...
		return:			[integer!]			"Result length or < 0"
	]


	; Type conversions

	to-integer: "atoi" [					"Parse string to integer."
		string			[c-string!]
		return:			[integer!]
	]
	to-float: "atof" [						"Parse string to floating point."
		string			[c-string!]
		return:			[float!]
	]


	; Parsing

	delimiter-length: "strspn" [			"Find out delimiter span."
		string			[c-string!]
		delimiters		[c-string!]
		return:			[size!]
	]
	value-length: "strcspn" [				"Find out token span."
		string			[c-string!]
		delimiters		[c-string!]
		return:			[size!]
	]
	find-delimiter: "strpbrk" [				"Search for delimiter."
		string			[c-string!]
		delimiters		[c-string!]
		return:			[c-string!]
	]
	split-next: "strtok" [					"Parse next token from string."
		string			[c-string!]
		delimiters		[c-string!]
		return:			[c-string!]
	]

	next-integer: "strtoul" [				"Parse next integer from string."
		string			[c-string!]
		next			[string-reference!]
		base			[integer!]			"2-36 or 0"
		return:			[unsigned-long!]
	]
	next-signed: "strtol" [					"Parse next (signed) integer from string."
		string			[c-string!]
		next			[string-reference!]
		base			[integer!]			"2-36 or 0"
		return:			[long!]
	]
	next-float: "strtod" [					"Parse next floating point number from string."
		string			[c-string!]
		next			[string-reference!]
		return:			[float!]
	]

	parse: "sscanf" [						"Read arguments from string."
		[variadic]
		; string		[c-string!]
		; format		[c-string!]
		;	value		[handle!]
		;	...
		return:			[integer!]			"Items parsed or EOF"
	]


	; Input/output

	_print-char: "putchar" [				"Print character to standard output."
		byte			[byte!]				"integer!"
		return:			[integer!]			"Char or EOF"
	]
	input-char: "getchar" [					"Read a character from standard input."
		return:			[integer!]			"Char or EOF"
	]


	_print-string-line: "puts" [			"Print line to standard output."
		line			[c-string!]
		return:			[integer!]			">= 0 or EOF"
	]
	input-line: "gets" [					"Read a line from standard input."
		line			[c-string!]			"No size check!"
		return:			[c-string!]
	]


	print-form: "printf" [					"Print arguments to standard output."
		[variadic]
		; format		[c-string!]
		;	value		[variant!]
		;	...
		return:			[integer!]			"Length printed or < 0"
	]

	input-form: "scanf" [					"Read arguments from standard input."
		[variadic]
		; format		[c-string!]
		;	value		[handle!]
		;	...
		return:			[integer!]			"Items parsed or EOF"
	]


	; File input/output

	open: "fopen" [							"Open file."
		name			[c-string!]
		mode			[c-string!]
		return:			[file!]
	]
	_reopen: "freopen" [					"Reopen file descriptor."
		name			[c-string!]
		mode			[c-string!]
		file			[file!]
		return:			[file!]
	]
	flush-file: "fflush" [					"Flush file(s)."
		file			[file!]				"NULL for all streams"
		return:			[integer!]			"0 or EOF"
	]
	close-file: "fclose" [					"Close file."
		file			[file!]
		return:			[integer!]			"0 or EOF"
	]


	_temporary-name: "tmpnam" [				"Create temporary file name."
		name			[c-string!]			"Normally NULL"
		return:			[c-string!]
	]
	temporary-file: "tmpfile" [				"Create temporary binary file for updating."
		return:			[file!]
	]


	_file-buffer: "setvbuf" [				"Configure buffering."
		file			[file!]
		buffer			[binary!]
		mode			[io-buffering!]
		size			[size!]
		return:			[integer!]
	]


	file-tail: "feof" [						"End-of-file status."
		file			[file!]
		return:			[integer!]
	]
	file-error: "ferror" [					"File status."
		file			[file!]
		return:			[integer!]
	]
	clear-status: "clearerr" [				"Clear file status."
		file			[file!]
	]


	file-index: "ftell" [					"File position."
		file			[file!]
		return:			[long!]				"0-based index or -1"
	]
	_file-at: "fseek" [						"Seek to file index."
		file			[file!]
		offset			[long!]
		origin			[seek-origin!]
		return:			[integer!]
	]
	file-at-head: "rewind" [				"Rewind file index and clear status."
		file			[file!]
	]
	_file-back: "ungetc" [					"Push byte back for rereading."
		byte			[byte!]				"integer!"
		file			[file!]
		return:			[integer!]			"Byte or EOF"
	]


	_write-byte: "fputc" [					"Write byte to file."
		byte			[byte!]				"integer!"
		file			[file!]
		return:			[integer!]			"Byte or EOF"
	]
	read-byte: "fgetc" [					"Read byte from file."
		file			[file!]
		return:			[integer!]			"Byte or EOF"
	]


	_write-line: "fputs" [					"Write line to text file."
		line			[c-string!]
		file			[file!]
		return:			[integer!]			">= 0 or EOF"
	]
	_read-line: "fgets" [					"Read line from text file."
		line			[c-string!]
		size			[integer!]
		file			[file!]
		return:			[c-string!]
	]


	_write-array: "fwrite" [				"Write binary array to file."
		array			[handle!]
		size			[size!]
		entries			[size!]
		file			[file!]
		return:			[size!]				"Chunks written"
	]
	read-array: "fread" [					"Read binary array from file."
		array			[handle!]
		size			[size!]
		entries			[size!]
		file			[file!]
		return:			[size!]				"Chunks read"
	]


	write-form: "fprintf" [					"Print arguments to file."
		[variadic]
		; file			[file!]
		; format		[c-string!]
		;	value		[variant!]
		;	...
		return:			[integer!]			"Length printed or < 0"
	]

	load: "fscanf" [						"Read arguments from text file."
		[variadic]
		; file			[file!]
		; format		[c-string!]
		;	value		[handle!]
		;	...
		return:			[integer!]			"Items parsed or EOF"
	]


	_delete: "remove" [						"Delete file."
		name			[c-string!]
		return:			[integer!]
	]
	_rename: "rename" [						"Rename file."
		old-name		[c-string!]
		new-name		[c-string!]
		return:			[integer!]
	]


	; Dates and time

	now-time: "time" [						"Current time."
		result			[pointer! [time!]]
		return:			[time!]				"-1: unknown"
	]
	form-time: "ctime" [					"Format internal time as string."
		time			[pointer! [time!]]
		return:			[c-string!]
	]
	subtract-time: "difftime" [				"time-1 - time-2"
		time-1			[time!]
		time-2			[time!]
		return:			[float!]			"Seconds"
	]

	form-date: "asctime" [					"Format date as string."
		date			[date!]
		return:			[c-string!]
	]
	_format-date: "strftime" [				"Format date as string."
		string			[c-string!]
		size			[size!]
		format			[c-string!]
		date			[date!]
		return:			[size!]				"Result length or 0"
	]

	to-date: "gmtime" [						"Convert internal time to UTC date."
		time			[pointer! [time!]]
		return:			[date!]
	]
	to-local-date: "localtime" [			"Convert internal time to local date."
		time			[pointer! [time!]]
		return:			[date!]
	]
	to-time: "mktime" [						"Convert date to internal time."
		date			[date!]
		return:			[time!]				"-1: unknown"
	]

	get-process-time: "clock" [				"CPU time used by process; wall-clock time on Windows!"
		return:			[clock!]			"-1: unknown"
	]


	; Number processing

	absolute: "abs" [
		number			[integer!]
		return:			[integer!]
	]

	; Random numbers

	random-seed: "srand" [					"Restart pseudo-random sequence with new seed (initially 1)."
		seed			[unsigned!]
	]
	random-integer: "rand" [				"Pseudo-random number from 0 thru RAND_MAX (at least 32767)."
		return:			[integer!]
	]


	; System interfacing

	get-env: "getenv" [						"Get system environment variable."
		name			[c-string!]
		return:			[c-string!]
	]

	call: "system" [						"Execute external system command."
		command			[c-string!]			"NULL to check for command processor"
		return:			[integer!]
	]

	quit-now: "abort" [						"Abort program with signal signal-abort (SIGABRT)."
	]

	_signal: "raise" [						"Send signal to self."
		signal			[signal!]
		return:			[integer!]
	]

	; Callback handlers

	#either target = 'ARM [
		_on-quit: "__cxa_atexit" [			"Register handler for normal program termination."
;			handler			[function! []]	"Callback"
			handler			[integer!]
			handle			[handle!]
			library-handle	[handle!]
			return:			[integer!]
		]
	][
		#either OS = 'Syllable [
			_on-quit: "__cxa_atexit" [		"Register handler for normal program termination."
;				handler			[function! []]	"Callback"
				handler			[integer!]
				handle			[handle!]
				library-handle	[handle!]
				return:			[integer!]
			]
		][
			_on-quit: "atexit" [			"Register handler for normal program termination."
;				handler			[function! []]	"Callback"
				handler			[integer!]
				return:			[integer!]
			]
		]
	]

	on-signal: "signal" [					"Register handlers for receiving system signals."
		signal			[signal!]
		handler			[function! [signal [signal!]]]	"Flag or callback"
;		return:			[function! [signal [signal!]]]
		return:			[handle!]			"Previous handler or SIGNAL-ERROR"
	]
]]


; Higher level interface


; Memory block processing

copy-part: function ["Copy memory range, return target."
	source			[binary!]
	target			[binary!]
	size			[size!]
	return:			[binary!]
][
	_copy-part target source size
]
move-part: function ["Copy possibly overlapping memory range, return target."
	source			[binary!]
	target			[binary!]
	size			[size!]
	return:			[binary!]
][
	_move-part target source size
]


; Character processing

control?: function ["Test for control character."
	char			[byte!]
	return:			[logic!]
][
	as-logic is-control as-integer char
]
printable?: function ["Test character for printability."
	char			[byte!]
	return:			[logic!]
][
	as-logic is-printable as-integer char
]
graphical?: function ["Test character for displayability: printable and not whitespace."
	char			[byte!]
	return:			[logic!]
][
	as-logic is-graphical as-integer char
]
punctuation?: function ["Test character for punctuation."
	char			[byte!]
	return:			[logic!]
][
	as-logic is-punctuation as-integer char
]
blank?: function ["Test character for whitespace."
	char			[byte!]
	return:			[logic!]
][
	as-logic is-blank as-integer char
]
alphanumeric?: function ["Test character for alphanumeric."
	char			[byte!]
	return:			[logic!]
][
	as-logic is-alphanumeric as-integer char
]
alphabetic?: function ["Test character for alphabetic."
	char			[byte!]
	return:			[logic!]
][
	as-logic is-alphabetic as-integer char
]
digit?: function ["Test character for digit."
	char			[byte!]
	return:			[logic!]
][
	as-logic is-digit as-integer char
]
hex?: function ["Test character for hexadecimal digit."
	char			[byte!]
	return:			[logic!]
][
	as-logic is-hex as-integer char
]
uppercase?: function ["Test character for uppercase."
	char			[byte!]
	return:			[logic!]
][
	as-logic is-uppercase as-integer char
]
lowercase?: function ["Test character for lowercase."
	char			[byte!]
	return:			[logic!]
][
	as-logic is-lowercase as-integer char
]


; String processing

copy-string: function ["Copy string including tail marker, return target."
	source			[c-string!]
	target			[c-string!]
	return:			[c-string!]
][
	_copy-string target source
]
copy-string-part: function ["Copy string range, return target."
	source			[c-string!]
	target			[c-string!]
	size			[size!]
	return:			[c-string!]
][
	_copy-string-part target source size
]

format: function ["Format argument as string."
	string			[c-string!]  "WARNING: must be big enough!"
	format			[c-string!]
	value			[variant!]
	return:			[logic!]
][
	0 <= format-any [string format value]  ; WARN?: error possible?
]


; Type conversions

form-integer: function ["Format integer as string."
	number			[integer!]
	return:			[c-string!]
	/local			result
][
	result: make-c-string 11  ; Max 32 bits

	if as-logic result [
		format-any [result "%u" number]  ; FIXME?: error possible?
	]
	result
]
form-signed: function ["Format signed integer as string."
	number			[integer!]
	return:			[c-string!]
	/local			result
][
	result: make-c-string 12  ; Max 32 bits "-2147483648"

	if as-logic result [
		format-any [result "%i" number]  ; FIXME?: error possible?
	]
	result
]
form-hex: function ["Format integer as hexadecimal string."
	number			[integer!]
	length			[integer!]  "Number of digits"
	return:			[c-string!]
	/local			result
][
	result: make-c-string 9  ; Max 32 bits "FFFFFFFF"

	if as-logic result [
		format-any [result "%0*X" length number]  ; FIXME?: error possible?
	]
	result
]
form-octal: function ["Format integer as octal string."
	number			[integer!]
	return:			[c-string!]
	/local			result
][
	result: make-c-string 12  ; Max 32 bits

	if as-logic result [
		format-any [result "%o" number]  ; FIXME?: error possible?
	]
	result
]

form-float: function ["Format floating point as string."
	number			[float!]
	return:			[c-string!]
	/local			result
][
	result: make-c-string 18  ; Max 64 bits; FIXME?: enough?

	if as-logic result [
		format-any [result "%g" number]  ; FIXME?: error possible?
	]
	result
]


; Parsing

parse-hex: function ["Parse hexadecimal string to integer."
	string			[c-string!]
	number			[pointer! [integer!]]
	return:			[logic!]
][
	1 = parse [string "%x"  as-handle number]
]
parse-octal: function ["Parse octal string to integer."
	string			[c-string!]
	number			[pointer! [integer!]]
	return:			[logic!]
][
	1 = parse [string "%o"  as-handle number]
]


; Input/output

print-char: function ["Print character to standard output."
	char			[byte!]
	return:			[logic!]
][
	0 <= _print-char char
]
print-newline: function ["Print newline to standard output."
	return:			[logic!]
][
	0 <= _print-char #"^/"
]


print-string-line: function ["Print line to standard output."
	line			[c-string!]
	return:			[logic!]
][
	0 <= _print-string-line line
]
input: function ["Return a line read from standard input."
	return:			[c-string!]  "WARNING: no size check!"
	/local			line
][
	line: make-c-string 100'001

	if as-logic line [
		either none? input-line line [  ; FIXME: no size check!
			free-any line
			return null
		][
			line: as-c-string resize as-binary line  (length? line) + 1
		]
	]
	line
]
ask: function ["Prompt for input, then return a line read from standard input."
	question		[c-string!]
	return:			[c-string!]
][
	print question
	input
]


print-string: function ["Print string to standard output."
	string			[c-string!]
	return:			[logic!]
][
	positive? print-form ["%s"  as variant! string]
]


print-integer: function ["Print integer to standard output."
	number			[integer!]
	return:			[logic!]
][
	positive? print-form ["%u" number]
]
print-signed: function ["Print signed integer to standard output."
	number			[integer!]
	return:			[logic!]
][
	positive? print-form ["%i" number]
]
print-hex: function ["Print hexadecimal integer to standard output."
	number			[integer!]
	return:			[logic!]
][
	positive? print-form ["%X" number]
]
print-octal: function ["Print octal integer to standard output."
	number			[integer!]
	return:			[logic!]
][
	positive? print-form ["%o" number]
]

input-decimal: function ["Parse integer from decimal string on standard input."
	number			[pointer! [integer!]]
	return:			[logic!]
][
	1 = input-form ["%u"  as-handle number]
]
input-signed: function ["Parse integer from (signed) decimal string on standard input."
	number			[pointer! [integer!]]
	return:			[logic!]
][
	1 = input-form ["%d"  as-handle number]
]
input-integer: function ["Parse integer from decimal, hexadecimal or octal string on standard input."
	number			[pointer! [integer!]]
	return:			[logic!]
][
	1 = input-form ["%i"  as-handle number]
]
input-hex: function ["Parse integer from hexadecimal string on standard input."
	number			[pointer! [integer!]]
	return:			[logic!]
][
	1 = input-form ["%x"  as-handle number]
]
input-octal: function ["Parse integer from octal string on standard input."
	number			[pointer! [integer!]]
	return:			[logic!]
][
	1 = input-form ["%o"  as-handle number]
]


print-float: function ["Print floating point to standard output."
	number			[float!]
	return:			[logic!]
][
	positive? print-form ["%g" number]
]
input-float: function ["Parse floating point from string on standard input."
	number			[pointer! [float!]]
	return:			[logic!]
][
	1 = input-form ["%lf"  as-handle number]
]


; File input/output

open-new: function ["Open file for (over)writing."
	name			[c-string!]
	return:			[file!]
][
	open name "w"
]
open-new-binary: function ["Open binary file for (over)writing."
	name			[c-string!]
	return:			[file!]
][
	open name "wb"
]
open-new-seek: function ["Open file for (over)writing."
	name			[c-string!]
	return:			[file!]
][
	open name "w+"
]
open-new-seek-binary: function ["Open binary file for (over)writing."
	name			[c-string!]
	return:			[file!]
][
	open name "w+b"
]
open-read: function ["Open file for reading."
	name			[c-string!]
	return:			[file!]
][
	open name "r"
]
open-read-binary: function ["Open binary file for reading."
	name			[c-string!]
	return:			[file!]
][
	open name "rb"
]
open-update: function ["Open file for updating."
	name			[c-string!]
	return:			[file!]
][
	open name "r+"
]
open-update-binary: function ["Open binary file for updating."
	name			[c-string!]
	return:			[file!]
][
	open name "r+b"
]
open-append: function ["Open file for appending."
	name			[c-string!]
	return:			[file!]
][
	open name "a"
]
open-append-binary: function ["Open binary file for appending."
	name			[c-string!]
	return:			[file!]
][
	open name "ab"
]
open-append-seek: function ["Open file for appending."
	name			[c-string!]
	return:			[file!]
][
	open name "a+"
]
open-append-seek-binary: function ["Open binary file for appending."
	name			[c-string!]
	return:			[file!]
][
	open name "a+b"
]

reopen: function ["Reopen file descriptor."
	name			[c-string!]
	mode			[c-string!]
	file			[file!]
	return:			[logic!]
][
	as-logic _reopen name mode file
]
flush: function ["Flush file(s)."
	file			[file!]  "NULL for all streams"
	return:			[logic!]
][
	not as-logic flush-file file
]
close: function ["Close file."
	file			[file!]
	return:			[logic!]
][
	not as-logic close-file file
]


temporary-name: function ["Create temporary file name."
	return:			[c-string!]
][
	_temporary-name null
]


file-buffer: function ["Configure buffering."
	file			[file!]
	buffer			[binary!]
	mode			[integer!]
	size			[size!]
	return:			[logic!]
][
	not as-logic _file-buffer file buffer mode size
]


file-tail?: function ["End-of-file status."
	file			[file!]
	return:			[logic!]
][
	as-logic file-tail file
]
file-error?: function ["File status."
	file			[file!]
	return:			[logic!]
][
	as-logic file-error file
]


file-at: function ["Seek to file index."
	file			[file!]
	offset			[long!]
	origin			[integer!]
	return:			[logic!]
][
	not as-logic _file-at file offset origin
]
file-back: function ["Push byte back for rereading."
	byte			[byte!]
	file			[file!]
	return:			[logic!]
][
	0 <= _file-back byte file
]


write-byte: function ["Write byte to file."
	byte			[byte!]
	file			[file!]
	return:			[logic!]
][
	0 <= _write-byte byte file
]


write-line: function ["Write line to text file."
	line			[c-string!]
	file			[file!]
	return:			[logic!]
][
	0 <= _write-line line file
]
read-line: function ["Read line from text file."
	line			[c-string!]
	size			[integer!]
	file			[file!]
	return:			[logic!]
][
	as-logic _read-line line size file
]


write-array: function ["Write binary array to file."
	array			[handle!]
	size			[size!]
	entries			[size!]
	file			[file!]
	return:			[logic!]
][
	entries = _write-array array size entries file
]


write-integer: function ["Print integer to file."
	file			[file!]
	number			[integer!]
	return:			[logic!]
][
	positive? write-form [file "%u" number]
]
write-signed: function ["Print signed integer to file."
	file			[file!]
	number			[integer!]
	return:			[logic!]
][
	positive? write-form [file "%i" number]
]
write-hex: function ["Print hexadecimal integer to file."
	file			[file!]
	number			[integer!]
	return:			[logic!]
][
	positive? write-form [file "%X" number]
]
write-octal: function ["Print octal integer to file."
	file			[file!]
	number			[integer!]
	return:			[logic!]
][
	positive? write-form [file "%o" number]
]

load-decimal: function ["Read integer from decimal string in text file."
	file			[file!]
	number			[pointer! [integer!]]
	return:			[logic!]
][
	1 = load [file "%u"  as-handle number]
]
load-signed: function ["Read integer from (signed) decimal string in text file."
	file			[file!]
	number			[pointer! [integer!]]
	return:			[logic!]
][
	1 = load [file "%d"  as-handle number]
]
load-integer: function ["Read integer from decimal, hexadecimal or octal string in text file."
	file			[file!]
	number			[pointer! [integer!]]
	return:			[logic!]
][
	1 = load [file "%i"  as-handle number]
]
load-hex: function ["Read integer from hexadecimal string in text file."
	file			[file!]
	number			[pointer! [integer!]]
	return:			[logic!]
][
	1 = load [file "%x"  as-handle number]
]
load-octal: function ["Read integer from octal string in text file."
	file			[file!]
	number			[pointer! [integer!]]
	return:			[logic!]
][
	1 = load [file "%o"  as-handle number]
]


write-float: function ["Print floating point to text file."
	file			[file!]
	number			[float!]
	return:			[logic!]
][
	positive? write-form [file "%g" number]
]
load-float: function ["Read floating point from text file."
	file			[file!]
	number			[pointer! [float!]]
	return:			[logic!]
][
	1 = load [file "%lf"  as-handle number]
]


delete: function ["Delete file."
	name			[c-string!]
	return:			[logic!]
][
	not as-logic _delete name
]
rename: function ["Rename file."
	old-name		[c-string!]
	new-name		[c-string!]
	return:			[logic!]
][
	not as-logic _rename old-name new-name
]


read-file-binary: function ["Read binary file."
	name			[c-string!]
	size			[pointer! [size!]]
	return:			[binary!]
	/local file data
][
	data: as-binary 0
	file: open-read-binary name

	if as-logic file [
		if file-at file 0 seek-end [
			size/value: file-index file

			if size/value <> -1 [
				data: allocate size/value

				if as-logic data [
					file-at-head file

					if size/value <> read-array as-handle data  1 size/value file [
						free data
						data: null
					]
				]
			]
		]
		unless close file [  ; FIXME: status may be replaced
			if as-logic data [
				free data
				data: null
			]
		]
	]
	data
]

read-file: function ["Read text file."
	name			[c-string!]
	return:			[c-string!]
	/local file size length tail text safe
][
	text: as-binary 0
	file: open-read name

	if as-logic file [
		if file-at file 0 seek-end [
			size: file-index file

			if size <> -1 [
				text: allocate size + 1

				if as-logic text [
					file-at-head file
					length: read-array as-handle text  1 size file

					either length > size [  ; Buffer overflow; should never happen
						free text
						text: null
						; WARN: file error not necessarily set
					][
						tail: length + 1
						text/tail: null-byte

						if length < size [
							either file-error? file [
								free text
								text: null
							][	; Windows presumably converted newlines
								safe: text
								text: resize text tail

								if none? text [free safe]
							]
						]
					]
				]
			]
		]
		unless close file [  ; FIXME: status may be replaced
			if as-logic text [
				free text
				text: null
			]
		]
	]
	as-c-string text
]

write-file-binary: function ["Write binary file."
	name			[c-string!]
	data			[binary!]
	size			[size!]
	return:			[logic!]
	/local file ok?
][
	file: open-new-binary name

	either none? file [
		no
	][
		ok?: write-array as-handle data  1 size file

		all [close file  ok?]  ; FIXME: status may be replaced
	]
]

write-file: function ["Write text file."
	name			[c-string!]
	text			[c-string!]
	return:			[logic!]
	/local file ok?
][
	file: open-new name

	either none? file [
		no
	][
		ok?: write-array as-handle text  1  length? text  file

		all [close file  ok?]  ; FIXME: status may be replaced
	]
]


; Dates and time

now: function ["Current time."
	return:			[date!]  "NULL: unknown"
	/local			time
][
	time: now-time null

	either time = -1 [null] [to-local-date :time]
]
now-utc: function ["Current universal time."
	return:			[date!]  "NULL: unknown"
	/local			time
][
	time: now-time null

	either time = -1 [null] [to-date :time]
]
format-date: function ["Format date as string."
	string			[c-string!]
	size			[size!]
	format			[c-string!]
	date			[date!]
	return:			[logic!]
][
	positive? _format-date string size format date
]

get-process-seconds: function ["CPU time used by process; wall-clock time on Windows!"
	return:			[float!]  "-1: unknown"
	/local			time
][
	time: get-process-time

	either time = -1 [
		-1.0
	][
;		TODO: optimise
		(to-float form-integer time) /
		to-float form-integer clocks-per-second
	]
]


; Random numbers

random-seed-secure: function ["Restart pseudo-random sequence with time based seed."
][
	random-seed now-time null
]
random: function ["Pseudo-random number from 1 thru RANGE."
	range			[integer!]
	return:			[integer!]
][
	random-integer // range + 1  ; FIXME: check max-random
]


; System interfacing

signal: function ["Send signal to self."
	signal			[signal!]
	return:			[logic!]
][
	not as-logic _signal signal
]

on-quit: function ["Register handler for normal program termination."
;	handler			[function! []]  "Callback"
	handler			[integer!]  "Callback"
	return:			[logic!]
][
	#either target = 'ARM [
		not as-logic _on-quit handler null null
	][
		#either OS = 'Syllable [
			not as-logic _on-quit handler null null
		][
			not as-logic _on-quit handler
		]
	]
]


; Program arguments

taken-arguments: 0

get-args-count: function ["Return number of program arguments, excluding program name."
	return:			[integer!]
][
	system/args-count - taken-arguments - 1
]
get-argument: function ["Return a program argument."
	offset			[integer!]  "0: program file name"
	return:			[c-string!]  "Argument, or NULL"
	/local argument string out length
][
	either offset <= get-args-count [
		argument: system/args-list + either zero? offset [0] [taken-arguments + offset]

		#either OS = 'Windows [
			string: argument/item
			length: length? string

			either all [
				length >= 2
				string/1		= #"^""
				string/length	= #"^""
			][
				length: length - 1
				out: make-c-string length

				if as-logic out [
					copy-string-part string + 1  out  length - 1
					out/length: null-byte  ; For safety?
				]
			][
				out: make-c-string length + 1

				if as-logic out [
					copy-string string out
				]
			]
			out
		][
			argument/item
		]
	][
		null
	]
]
take-argument: function ["Consume and return next program argument."
	return:			[c-string!]  "Argument, or NULL"
	/local			argument
][
	either get-args-count >= 1 [
		argument: get-argument 1
		taken-arguments: taken-arguments + 1
		argument
	][
		null
	]
]
end-argument: function ["Clean up program argument."
	argument		[c-string!]
][
	#if OS = 'Windows [free-any argument]
]
