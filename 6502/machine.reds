Red/System [
	Title:		"Skeletal Abstracted Machine for CPU Emulator"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 1995,1996,2012-2014 Kaj de Vos. All rights reserved."
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
		Red/System
		%6502/common.reds
	}
	Purpose: {
		Machine emulation abstracted away from CPU emulator,
		so they can be implemented separately.
	}
	Tabs:		4
]


#include %common.reds


#define IRQ?		no

memory: context [

	; Memory management

	map!:			alias struct! [item [binary!]]

	read-map: as map! allocate 20h * size? map!

	if null? read-map [
		print-line "Failed to allocate read memory map!"
		quit 1
	]

	write-map: as map! allocate 20h * size? map!

	if null? write-map [
		print-line "Failed to allocate write memory map!"
		quit 2
	]


	; Main memory

	RAM: allocate 00010000h

	if null? RAM [
		print-line "Failed to allocate RAM memory!"
		quit 10
	]

	read-list: read-map
	write-list: write-map
	segment: RAM

	until [
		read-list/item: segment
		write-list/item: segment

		read-list: read-list + 1
		write-list: write-list + 1
		segment: segment + 0800h
		RAM + 00010000h = segment
	]

	; Dummy block to catch write attempts to ROM

	dummy: allocate 0800h

	if null? dummy [
		print-line "Failed to allocate dummy memory block!"
		quit 11
	]


	; ROM

	ROM: as-binary 0
	size: 0
	argument: get-argument 1

	either null? argument [
		argument: get-argument 0
		print-wide ["Usage:" argument "<ROM file>" newline]
	][
		ROM: read-file-binary argument :size

		if null? ROM [
			print-line "Error reading ROM file!"
			quit 20
		]
		if size and 07FFh <> 0 [
			print-line "ROM file needs to be a multiple of 2 KB."
			free ROM
			quit 21
		]
		if size >= 00010000h [
			print-line "ROM file cannot be larger than 62 KB."
			free ROM
			quit 22
		]

		; WARN: use read-list & write-list from RAM setup
		segment: ROM + size

		until [
			read-list: read-list - 1
			write-list: write-list - 1
			segment: segment - 0800h

			read-list/item: segment
			write-list/item: dummy  ; Read-only

			segment = ROM
		]
	]
	end-argument argument


	; Access

	block: function [
		address		[word!]
		return:		[binary!]
		/local block
	][
		block: read-map + (address >>> 11)
		block/item
	]
	pointer: function [
		address		[word!]
		return:		[binary!]
		/local block
	][
		block: read-map + (address >>> 11)
		block/item + (address and 07FFh)
	]

	read: function [
		address		[word!]
		return:		[byte!]
		/local block pointer
	][
		block: read-map + (address >>> 11)
		pointer: block/item + (address and 07FFh)
		pointer/value
	]
	write: function [
		address		[word!]
		value		[byte!]
		/local block pointer
	][
		block: write-map + (address >>> 11)
		pointer: block/item + (address and 07FFh)
		pointer/value: value
	]

]
