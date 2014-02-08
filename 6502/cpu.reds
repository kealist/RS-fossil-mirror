Red/System [
	Title:		"6502 CPU Emulator"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 1995,1996,2012 Kaj de Vos. All rights reserved."
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
		Red/System >= 0.3.1
		%6502/common.reds
	}
	Purpose: {
		Emulates an 8-bit 6502 processor and a Memory Management Unit with 2 KB pages.
		Originally the core of an Atari XL/XE emulator.
	}
	Notes: {
		Read operations on double-byte address values are currently hardwired for little-endian.
	}
	Tabs:		4
]


#include %common.reds


#define low-byte (word)		[(as-byte word)]  ; and FFh
#define high-byte (word)	[(as-byte word >>> 8)]  ; and FFh


; CPU operations

#define get-PC [(PC-block or PC-offset)]

#define set-PC [
	PC-block: address and F800h
	PC-offset: address and 07FFh
	PC-pointer: (memory/block PC-block) + PC-offset
]

#define jump-indirect (vector') [
	word-pointer: as pointer! [word!] memory/pointer vector'
	address: word-pointer/value and FFFFh
	set-PC
]

#define interrupt (interrupt' vector') [
	interrupt': function [
		/local byte-pointer word-pointer address
	][
		address: get-PC
		push-address

		push-status
		I: as-byte I-bit

		jump-indirect (vector')
	]
]

#define increment-PC [
	either PC-offset < 07FFh [
		PC-offset: PC-offset + 1
		PC-pointer: PC-pointer + 1
	][
		PC-block: PC-block + 0800h and FFFFh
		PC-offset: 0

		PC-pointer: memory/block PC-block
	]
]

#define increment-PC-2 [
	PC-offset: PC-offset + 2

	either PC-offset < 0800h [
		PC-pointer: PC-pointer + 2
	][
		PC-block: PC-block + 0800h and FFFFh
		PC-offset: PC-offset and 07FFh

		PC-pointer: (memory/block PC-block) + PC-offset
	]
]

; Addressing modes

#define get-ZP-pointer [
	either PC-offset < 07FEh [
		pointer: memory/RAM + as-integer PC-pointer/2

		PC-offset: PC-offset + 2
		PC-pointer: PC-pointer + 2
	][
		PC-block: PC-block + 0800h and FFFFh

		either PC-offset = 07FEh [
			pointer: memory/RAM + as-integer PC-pointer/2

			PC-offset: 0
			PC-pointer: memory/block PC-block
		][	; 07FFh
			PC-pointer: memory/block PC-block

			pointer: memory/RAM + as-integer PC-pointer/value

			PC-offset: 1
			PC-pointer: PC-pointer + 1
		]
	]
]

#define get-indexed-ZP-pointer (index') [
	either PC-offset < 07FEh [
		pointer: memory/RAM + as-integer  PC-pointer/2 + index'

		PC-offset: PC-offset + 2
		PC-pointer: PC-pointer + 2
	][
		PC-block: PC-block + 0800h and FFFFh

		either PC-offset = 07FEh [
			pointer: memory/RAM + as-integer  PC-pointer/2 + index'

			PC-offset: 0
			PC-pointer: memory/block PC-block
		][	; 07FFh
			PC-pointer: memory/block PC-block

			pointer: memory/RAM + as-integer  PC-pointer/value + index'

			PC-offset: 1
			PC-pointer: PC-pointer + 1
		]
	]
]

#define get-jump-address [
	either PC-offset < 07FEh [
		word-pointer: as pointer! [word!] PC-pointer + 1
		address: word-pointer/value and FFFFh
	][
		either PC-offset = 07FEh [
			address: as word! PC-pointer/2

			byte-pointer: memory/block PC-block
			address: (as word! byte-pointer/value) << 8 or address
		][	; 07FFh
			word-pointer: as pointer! [word!] memory/block PC-block + 0800h and FFFFh
			address: word-pointer/value and FFFFh
		]
	]
]

#define get-address [
	either PC-offset < 07FDh [
		pointer: as pointer! [word!] PC-pointer + 1
		address: pointer/value and FFFFh

		PC-offset: PC-offset + 3
		PC-pointer: PC-pointer + 3
	][
		PC-block: PC-block + 0800h and FFFFh

		switch PC-offset [
		07FDh [
			pointer: as pointer! [word!] PC-pointer + 1
			address: pointer/value and FFFFh

			PC-offset: 0
			PC-pointer: memory/block PC-block
		]
		07FFh [
			PC-pointer: memory/block PC-block

			pointer: as pointer! [word!] PC-pointer
			address: pointer/value and FFFFh

			PC-offset: 2
			PC-pointer: PC-pointer + 2
		]
		default [ ; 07FEh
			address: as word! PC-pointer/2

			PC-pointer: memory/block PC-block
			address: (as word! PC-pointer/value) << 8 or address

			PC-offset: 1
			PC-pointer: PC-pointer + 1
		]]
	]
]

#define get-indexed-address (index') [
	either PC-offset < 07FDh [
		pointer: as pointer! [word!] PC-pointer + 1
		address: pointer/value + index' and FFFFh

		PC-offset: PC-offset + 3
		PC-pointer: PC-pointer + 3
	][
		PC-block: PC-block + 0800h and FFFFh

		switch PC-offset [
		07FDh [
			pointer: as pointer! [word!] PC-pointer + 1
			address: pointer/value + index' and FFFFh

			PC-offset: 0
			PC-pointer: memory/block PC-block
		]
		07FFh [
			PC-pointer: memory/block PC-block

			pointer: as pointer! [word!] PC-pointer
			address: pointer/value + index' and FFFFh

			PC-offset: 2
			PC-pointer: PC-pointer + 2
		]
		default [ ; 07FEh
			address: as word! PC-pointer/2

			PC-pointer: memory/block PC-block
			address: (as word! PC-pointer/value) << 8 or address + index' and FFFFh

			PC-offset: 1
			PC-pointer: PC-pointer + 1
		]]
	]
]

#define get-indirect-address-X [
	either PC-offset < 07FEh [
		ZP-address: PC-pointer/2 + X

		PC-offset: PC-offset + 2
		PC-pointer: PC-pointer + 2
	][
		PC-block: PC-block + 0800h and FFFFh

		either PC-offset = 07FEh [
			ZP-address: PC-pointer/2 + X

			PC-offset: 0
			PC-pointer: memory/block PC-block
		][	; 07FFh
			PC-pointer: memory/block PC-block

			ZP-address: PC-pointer/value + X

			PC-offset: 1
			PC-pointer: PC-pointer + 1
		]
	]
	either ZP-address = as-byte FFh [
		address: (as word! memory/RAM/1) << 8 or as-integer memory/RAM/0100h
	][
		pointer: as pointer! [word!] memory/RAM + as-integer ZP-address
		address: pointer/value and FFFFh
	]
]

#define get-indirect-address-Y [
	either PC-offset < 07FEh [
		ZP-address: PC-pointer/2 + X

		PC-offset: PC-offset + 2
		PC-pointer: PC-pointer + 2
	][
		PC-block: PC-block + 0800h and FFFFh

		either PC-offset = 07FEh [
			ZP-address: PC-pointer/2 + X

			PC-offset: 0
			PC-pointer: memory/block PC-block
		][	; 07FFh
			PC-pointer: memory/block PC-block

			ZP-address: PC-pointer/value + X

			PC-offset: 1
			PC-pointer: PC-pointer + 1
		]
	]
	either ZP-address = as-byte FFh [
		address: (as word! memory/RAM/1) << 8 or (as-integer memory/RAM/0100h) + Y and FFFFh
	][
		pointer: as pointer! [word!] memory/RAM + as-integer ZP-address
		address: pointer/value + Y and FFFFh
	]
]

; Partial instructions

#define load-register (register') [
	register': pointer/value
	!Z: register'
	N: register'
]
#define read-register (register') [
	register': memory/read address
	!Z: register'
	N: register'
]

#define push-status [
	byte-pointer: stack + as-integer S
	byte-pointer/value:
		N and (as-byte N-bit)
		or (V >>> 1 and as-byte V-bit)
		or (as-byte P-unused-bit)
		or B or D or I
		or (either as-logic !Z [0] [Z-bit])  ; !
		or (C and as-byte C-bit)

	S: S - 1
]
#define pull-status [
		; !
		S: S + 1
		byte-pointer: stack + as-integer S
		N: byte-pointer/value
		!Z: N and (as-byte Z-bit) xor as-byte Z-bit

		V: N << 1
		B: N and as-byte B-bit
		D: N and as-byte D-bit
		I: N and as-byte I-bit
		C: N
]

#define push-address [
	either S = as-byte 0 [
		stack/value: high-byte (address)
		byte-pointer: stack + FFh
		byte-pointer/value: low-byte (address)

		S: as-byte FEh
	][
		;word-pointer: as pointer! [word!] stack + as-integer S - 1
		;word-pointer/value: address
		byte-pointer: stack + as-integer S
		byte-pointer/value: high-byte (address)
		byte-pointer: byte-pointer - 1
		byte-pointer/value: low-byte (address)

		S: S - 2
	]
]

#define ADC (operand') [
	byte: operand'

	either as-logic D [  ; Decimal mode
		word: (as word! A) and 0Fh + (byte and as-byte 0Fh) + (C and as-byte C-bit)

		if word > 9 [word: word + 6]  ; Decimal carry

		word: word + (A and as-byte F0h) + (byte and as-byte F0h)

		if word > 99h [word: word + 60h]  ; Decimal carry

		result/value: word
	][
		result/value: (as word! A) + byte + (C and as-byte C-bit)
	]
	V: A xor !Z  and not  A xor byte
	N: !Z
	A: !Z
]
#define SBC (operand') [
	byte: operand'

	either as-logic D [  ; Decimal mode
		word: (as word! A) and 0Fh - (byte and as-byte 0Fh) - ((not C) and as-byte C-bit)
		C: as-byte word and 10h

		if as-logic C [word: word - 6 and 0Fh]  ; Decimal borrow

		result/value: word + (A and as-byte F0h) - (byte and as-byte F0h) - C

		if as-logic C [result/value: result/value - 60h]  ; Decimal borrow

		C: not C
	][
		result/value: (as word! A) - byte - ((not C) and as-byte C-bit)
	]
	V: A xor byte and (A xor !Z)
	N: !Z
	A: !Z
]


; CPU instructions

#define CLx (instruction' flag') [
	instruction': does [
		flag': as-byte 0

		increment-PC
	]
]
#define SEx (instruction' flag' bit') [
	instruction': does [
		flag': as-byte bit'

		increment-PC
	]
]

#define Txy (instruction' to' from') [
	instruction': does [
		to': from'
		!Z: from'
		N: from'

		increment-PC
	]
]

#define LDx-immediate (instruction' register') [
	instruction': does [
		increment-PC

		register': PC-pointer/value
		!Z: register'
		N: register'

		increment-PC
	]
]

#define LDx-ZP (instruction' register') [
	instruction': function [
		/local pointer
	][
		get-ZP-pointer
		load-register (register')
	]
]
#define STx-ZP (instruction' register') [
	instruction': function [
		/local pointer
	][
		get-ZP-pointer
		pointer/value: register'
	]
]

#define LDx-ZP-indexed (instruction' register' index') [
	instruction': function [
		/local pointer
	][
		get-indexed-ZP-pointer (index')
		load-register (register')
	]
]
#define STx-ZP-indexed (instruction' register' index') [
	instruction': function [
		/local pointer
	][
		get-indexed-ZP-pointer (index')
		pointer/value: register'
	]
]

#define LDx-absolute (instruction' register') [
	instruction': function [
		/local pointer address
	][
		get-address
		read-register (register')
	]
]
#define STx-absolute (instruction' register') [
	instruction': function [
		/local pointer address
	][
		get-address
		memory/write address register'
	]
]

#define LDx-absolute-indexed (instruction' register' index') [
	instruction': function [
		/local pointer address
	][
		get-indexed-address (index')
		read-register (register')
	]
]
#define STx-absolute-indexed (instruction' register' index') [
	instruction': function [
		/local pointer address
	][
		get-indexed-address (index')
		memory/write address register'
	]
]

#define bump (instruction' register' operation') [
	instruction': does [
		register': register' operation' 1
		!Z: register'
		N: register'

		increment-PC
	]
]

#define bump-ZP (instruction' operation') [
	instruction': function [
		/local pointer
	][
		get-ZP-pointer

		!Z: pointer/value operation' 1
		N: !Z

		pointer/value: !Z
	]
]
#define bump-ZP-X (instruction' operation') [
	instruction': function [
		/local pointer
	][
		get-indexed-ZP-pointer (X)

		!Z: pointer/value operation' 1
		N: !Z

		pointer/value: !Z
	]
]

#define bump-absolute (instruction' operation') [
	instruction': function [
		/local pointer address
	][
		get-address

		!Z: memory/read address  operation' 1  ; !
		N: !Z

		memory/write address !Z  ; !
	]
]
#define bump-absolute-X (instruction' operation') [
	instruction': function [
		/local pointer address
	][
		get-indexed-address (X)

		!Z: memory/read address  operation' 1  ; !
		N: !Z

		memory/write address !Z  ; !
	]
]

#define bitwise-immediate (instruction' operation') [
	instruction': does [
		increment-PC

		A: A operation' PC-pointer/value
		!Z: A
		N: A

		increment-PC
	]
]

#define bitwise-ZP (instruction' operation') [
	instruction': function [
		/local pointer
	][
		get-ZP-pointer

		A: A operation' pointer/value
		!Z: A
		N: A
	]
]
#define bitwise-ZP-X (instruction' operation') [
	instruction': function [
		/local pointer
	][
		get-indexed-ZP-pointer (X)

		A: A operation' pointer/value
		!Z: A
		N: A
	]
]

#define bitwise-absolute (instruction' operation') [
	instruction': function [
		/local pointer address
	][
		get-address

		A: A operation' memory/read address
		!Z: A
		N: A
	]
]
#define bitwise-absolute-indexed (instruction' operation' index') [
	instruction': function [
		/local pointer address
	][
		get-indexed-address (index')

		A: A operation' memory/read address
		!Z: A
		N: A
	]
]

#define bitwise-indirect-X (instruction' operation') [
	instruction': function [
		/local pointer ZP-address address
	][
		get-indirect-address-X

		A: A operation' memory/read address
		!Z: A
		N: A
	]
]
#define bitwise-indirect-Y (instruction' operation') [
	instruction': function [
		/local pointer ZP-address address
	][
		get-indirect-address-Y

		A: A operation' memory/read address
		!Z: A
		N: A
	]
]

#define compare-immediate (instruction' register') [
	instruction': does [
		increment-PC

		; !
		result/value: (as word! register') - PC-pointer/value
		N: !Z

		C: not C

		increment-PC
	]
]

#define compare-ZP (instruction' register') [
	instruction': function [
		/local pointer
	][
		get-ZP-pointer

		; !
		result/value: (as word! register') - pointer/value
		N: !Z

		C: not C
	]
]

#define compare-absolute (instruction' register') [
	instruction': function [
		/local pointer address
	][
		get-address

		; !
		result/value: (as word! register') - memory/read address
		N: !Z

		C: not C
	]
]
#define compare-absolute-indexed (instruction' index') [
	instruction': function [
		/local pointer address
	][
		get-indexed-address (index')

		; !
		result/value: (as word! A) - memory/read address
		N: !Z

		C: not C
	]
]

#define ADC-absolute-indexed (instruction' index') [
	instruction': function [
		/local pointer address byte word
	][
		get-indexed-address (index')
		ADC ((memory/read address))
	]
]
#define SBC-absolute-indexed (instruction' index') [
	instruction': function [
		/local pointer address byte word
	][
		get-indexed-address (index')
		SBC ((memory/read address))
	]
]

#define branch (instruction' flag') [
	instruction': function [
		/local pointer address offset
	][
		either flag' [
			either PC-offset = 07FFh [
				pointer: memory/block PC-block + 0800h and FFFFh
				offset: as-integer pointer/value
			][
				offset: as-integer PC-pointer/2
			]
			if offset >= 80h [  ; Negative
				offset: offset or FFFFFF00h  ; Make signed
			]
			PC-offset: PC-offset + 2 + offset

			either PC-offset and F800h = 0 [
				PC-pointer: PC-pointer + 2 + offset
			][
				PC-block: PC-offset and F800h + PC-block and FFFFh
				PC-offset: PC-offset and 07FFh

				PC-pointer: (memory/block PC-block) + PC-offset
			]
		][
			increment-PC-2
		]
	]
]


cpu: context [

	; CPU registers

	PC-block: declare word!
	PC-offset: declare word!
	PC-pointer: declare binary!

	stack: memory/RAM + 0100h
	S: declare byte!		; Stack pointer

	; WARN: Carry needs to be packed behind !Z tightly
	; FIXME: needs to be swapped for big-endian
	pad: declare integer!	; For alignment
	!Z: declare byte!
	C: declare byte!		; Carry
	result: as pointer! [integer!] :!Z

	A: declare byte!		; Accumulator

	X: declare byte!
	Y: declare byte!

	; Status register

	#enum status-bits! [
		N-bit:			80h
		V-bit:			40h
		P-unused-bit:	20h
		B-bit:			10h
		D-bit:			08
		I-bit:			04
		Z-bit:			02
		C-bit:			01
	]


	; CPU operations

	instructions: as typed-value! 0

	reset: function [
		/local word-pointer address
	][
		; ?

		N: as-byte 0
		V: as-byte 0
		B: as-byte 0
		D: as-byte 0
		I: as-byte 0

		!Z: as-byte 0
		C: as-byte 0

		S: as-byte FFh  ; ?

		jump-indirect (FFFCh)  ; Reset vector
	]

	interrupt (NMI FFFAh)  ; NMI vector
	interrupt (IRQ FFFEh)  ; IRQ vector

	tick: function [
		/local record instruction
	][
		print-form ["%04X: %02X  S: %02X  NV_BDIZC: %u%u1%u %u%u%u%u  A: %02X  X: %02X  Y: %02X^/"
			get-PC
				as variant! PC-pointer/value
			as variant! S

			as variant! N >>> 7
			as variant! V >>> 7
			as variant! B >>> 4
			as variant! D >>> 3
			as variant! I >>> 2
;			as variant! not as-logic !Z  ; FIXME: #344
			either as-logic !Z [0] [1]
			as variant! C and as-byte C-bit

			as variant! A
			as variant! X
			as variant! Y
		]
		record: instructions + as-integer PC-pointer/value
		instruction: as function! [] record/value

		instruction
	]


	; CPU instructions

	illegal-op-code: does [
		print-form ["^/Invalid instruction %02X encountered at address %04X!^/"
			as variant! PC-pointer/value
			get-PC
		]
		quit 30
	]


	NOP: does [increment-PC]

	CLx (CLC C)
	CLx (CLD D)
	CLx (CLV V)

	CLI: does [
		I: as-byte 0

		increment-PC

		if IRQ? [IRQ]
	]

	SEx (SEC C C-bit)
	SEx (SED D D-bit)
	SEx (SEI I I-bit)

	Txy (TAX X A)
	Txy (TAY Y A)
	Txy (TXA A X)
	Txy (TYA A Y)
	Txy (TSX X S)

	TXS: does [
		S: X
		increment-PC
	]

	PHA: function [
		/local pointer
	][
		pointer: stack + as-integer S
		pointer/value: A
		S: S - 1

		increment-PC
	]
	PLA: function [
		/local pointer
	][
		; !
		S: S + 1
		pointer: stack + as-integer S
		A: pointer/value
		!Z: A
		N: A

		increment-PC
	]

	PHP: function [
		/local byte-pointer
	][
		push-status
		increment-PC
	]
	PLP: function [
		/local byte-pointer
	][
		pull-status
		increment-PC

		if all [IRQ?  not as-logic I] [IRQ]
	]

	LDx-immediate (LDA-immediate A)
	LDx-immediate (LDX-immediate X)
	LDx-immediate (LDY-immediate Y)

	LDx-ZP (LDA-ZP A)
	LDx-ZP (LDX-ZP X)
	LDx-ZP (LDY-ZP Y)

	STx-ZP (STA-ZP A)
	STx-ZP (STX-ZP X)
	STx-ZP (STY-ZP Y)

	LDx-ZP-indexed (LDA-ZP-X A X)
	LDx-ZP-indexed (LDY-ZP-X Y X)
	LDx-ZP-indexed (LDX-ZP-Y X Y)

	STx-ZP-indexed (STA-ZP-X A X)
	STx-ZP-indexed (STY-ZP-X Y X)
	STx-ZP-indexed (STX-ZP-Y X Y)

	LDx-absolute (LDA-absolute A)
	LDx-absolute (LDX-absolute X)
	LDx-absolute (LDY-absolute Y)

	STx-absolute (STA-absolute A)
	STx-absolute (STX-absolute X)
	STx-absolute (STY-absolute Y)

	LDx-absolute-indexed (LDA-absolute-X A X)
	LDx-absolute-indexed (LDY-absolute-X Y X)
	LDx-absolute-indexed (LDA-absolute-Y A Y)
	LDx-absolute-indexed (LDX-absolute-Y X Y)

	STx-absolute-indexed (STA-absolute-X A X)
	STx-absolute-indexed (STA-absolute-Y A Y)

	LDA-indirect-X: function [
		/local pointer ZP-address address
	][
		get-indirect-address-X
		read-register (A)
	]
	LDA-indirect-Y: function [
		/local pointer ZP-address address
	][
		get-indirect-address-Y
		read-register (A)
	]

	STA-indirect-X: function [
		/local pointer ZP-address address
	][
		get-indirect-address-X
		memory/write address A
	]
	STA-indirect-Y: function [
		/local pointer ZP-address address
	][
		get-indirect-address-Y
		memory/write address A
	]

	bump (INX X +)
	bump (INY Y +)
	bump (DEX X -)
	bump (DEY Y -)

	bump-ZP (INC-ZP +)
	bump-ZP (DEC-ZP -)

	bump-ZP-X (INC-ZP-X +)
	bump-ZP-X (DEC-ZP-X -)

	bump-absolute (INC-absolute +)
	bump-absolute (DEC-absolute -)

	bump-absolute-X (INC-absolute-X +)
	bump-absolute-X (DEC-absolute-X -)

	bitwise-immediate (AND-immediate and)
	bitwise-immediate (ORA-immediate or)
	bitwise-immediate (EOR-immediate xor)

	bitwise-ZP (AND-ZP and)
	bitwise-ZP (ORA-ZP or)
	bitwise-ZP (EOR-ZP xor)

	bitwise-ZP-X (AND-ZP-X and)
	bitwise-ZP-X (ORA-ZP-X or)
	bitwise-ZP-X (EOR-ZP-X xor)

	bitwise-absolute (AND-absolute and)
	bitwise-absolute (ORA-absolute or)
	bitwise-absolute (EOR-absolute xor)

	bitwise-absolute-indexed (AND-absolute-X and X)
	bitwise-absolute-indexed (ORA-absolute-X or  X)
	bitwise-absolute-indexed (EOR-absolute-X xor X)
	bitwise-absolute-indexed (AND-absolute-Y and Y)
	bitwise-absolute-indexed (ORA-absolute-Y or  Y)
	bitwise-absolute-indexed (EOR-absolute-Y xor Y)

	bitwise-indirect-X (AND-indirect-X and)
	bitwise-indirect-X (ORA-indirect-X or)
	bitwise-indirect-X (EOR-indirect-X xor)

	bitwise-indirect-Y (AND-indirect-Y and)
	bitwise-indirect-Y (ORA-indirect-Y or)
	bitwise-indirect-Y (EOR-indirect-Y xor)

	BIT-ZP: function [
		/local pointer
	][
		get-ZP-pointer

		N: pointer/value
		V: N
		!Z: A and N
	]
	BIT-absolute: function [
		/local pointer address
	][
		get-address

		N: memory/read address
		V: N
		!Z: A and N
	]

	ASL-A: does [
		; !
		result/value: (as word! A) << 1
		N: !Z
		A: !Z

		increment-PC
	]
	LSR-A: does [
		C: A

		A: A >>> 1
		!Z: A
		N: A

		increment-PC
	]

	ROL-A: does [
		; !
		result/value: (as word! A) << 1 or (C-bit and as word! C)
		N: !Z
		A: !Z

		increment-PC
	]
	ROR-A: does [
		!Z: A
		result/value: result/value >>> 1
		N: !Z
		C: A
		A: !Z

		increment-PC
	]

	ASL-ZP: function [
		/local pointer
	][
		get-ZP-pointer

		result/value: (as word! pointer/value) << 1
		N: !Z

		pointer/value: !Z
	]
	LSR-ZP: function [
		/local pointer
	][
		get-ZP-pointer

		C: pointer/value
		!Z: C >>> 1
		N: !Z

		pointer/value: !Z
	]

	ROL-ZP: function [
		/local pointer
	][
		get-ZP-pointer

		; !
		result/value: (as word! pointer/value) << 1 or (C-bit and as word! C)
		N: !Z

		pointer/value: !Z
	]
	ROR-ZP: function [
		/local pointer
	][
		get-ZP-pointer

		!Z: pointer/value
		result/value: result/value >>> 1
		N: !Z
		C: pointer/value

		pointer/value: !Z
	]

	ASL-ZP-X: function [
		/local pointer
	][
		get-indexed-ZP-pointer (X)

		result/value: (as word! pointer/value) << 1
		N: !Z

		pointer/value: !Z
	]
	LSR-ZP-X: function [
		/local pointer
	][
		get-indexed-ZP-pointer (X)

		C: pointer/value
		!Z: C >>> 1
		N: !Z

		pointer/value: !Z
	]

	ROL-ZP-X: function [
		/local pointer
	][
		get-indexed-ZP-pointer (X)

		; !
		result/value: (as word! pointer/value) << 1 or (C-bit and as word! C)
		N: !Z

		pointer/value: !Z
	]
	ROR-ZP-X: function [
		/local pointer
	][
		get-indexed-ZP-pointer (X)

		!Z: pointer/value
		result/value: result/value >>> 1
		N: !Z
		C: pointer/value

		pointer/value: !Z
	]

	ASL-absolute: function [
		/local pointer address
	][
		get-address

		result/value: (as word! memory/read address) << 1
		N: !Z

		memory/write address !Z
	]
	LSR-absolute: function [
		/local pointer address
	][
		get-address

		C: memory/read address
		!Z: C >>> 1
		N: !Z

		memory/write address !Z
	]

	ROL-absolute: function [
		/local pointer address
	][
		get-address

		; !
		result/value: (as word! memory/read address) << 1 or (C-bit and as word! C)
		N: !Z

		memory/write address !Z
	]
	ROR-absolute: function [
		/local pointer address
	][
		get-address

		!Z: memory/read address
		N: !Z
		result/value: result/value >>> 1
		C: N
		N: !Z

		memory/write address !Z
	]

	ASL-absolute-X: function [
		/local pointer address
	][
		get-indexed-address (X)

		result/value: (as word! memory/read address) << 1
		N: !Z

		memory/write address !Z
	]
	LSR-absolute-X: function [
		/local pointer address
	][
		get-indexed-address (X)

		C: memory/read address
		!Z: C >>> 1
		N: !Z

		memory/write address !Z
	]

	ROL-absolute-X: function [
		/local pointer address
	][
		get-indexed-address (X)

		; !
		result/value: (as word! memory/read address) << 1 or (C-bit and as word! C)
		N: !Z

		memory/write address !Z
	]
	ROR-absolute-X: function [
		/local pointer address
	][
		get-indexed-address (X)

		!Z: memory/read address
		N: !Z
		result/value: result/value >>> 1
		C: N
		N: !Z

		memory/write address !Z
	]

	compare-immediate (CMP-immediate A)
	compare-immediate (CPX-immediate X)
	compare-immediate (CPY-immediate Y)

	compare-ZP (CMP-ZP A)
	compare-ZP (CPX-ZP X)
	compare-ZP (CPY-ZP Y)

	CMP-ZP-X: function [
		/local pointer
	][
		get-indexed-ZP-pointer (X)

		; !
		result/value: (as word! A) - pointer/value
		N: !Z

		C: not C
	]

	compare-absolute (CMP-absolute A)
	compare-absolute (CPX-absolute X)
	compare-absolute (CPY-absolute Y)

	compare-absolute-indexed (CMP-absolute-X X)
	compare-absolute-indexed (CMP-absolute-Y Y)

	CMP-indirect-X: function [
		/local pointer ZP-address address
	][
		get-indirect-address-X

		; !
		result/value: (as word! A) - memory/read address
		N: !Z

		C: not C
	]
	CMP-indirect-Y: function [
		/local pointer ZP-address address
	][
		get-indirect-address-Y

		; !
		result/value: (as word! A) - memory/read address
		N: !Z

		C: not C
	]

	ADC-immediate: function [
		/local byte word
	][
		increment-PC
		ADC (PC-pointer/value)
		increment-PC
	]
	SBC-immediate: function [
		/local byte word
	][
		increment-PC
		SBC (PC-pointer/value)
		increment-PC
	]

	ADC-ZP: function [
		/local pointer byte word
	][
		get-ZP-pointer
		ADC (pointer/value)
	]
	SBC-ZP: function [
		/local pointer byte word
	][
		get-ZP-pointer
		SBC (pointer/value)
	]

	ADC-ZP-X: function [
		/local pointer byte word
	][
		get-indexed-ZP-pointer (X)
		ADC (pointer/value)
	]
	SBC-ZP-X: function [
		/local pointer byte word
	][
		get-indexed-ZP-pointer (X)
		SBC (pointer/value)
	]

	ADC-absolute: function [
		/local pointer address byte word
	][
		get-address
		ADC ((memory/read address))
	]
	SBC-absolute: function [
		/local pointer address byte word
	][
		get-address
		SBC ((memory/read address))
	]

	ADC-absolute-indexed (ADC-absolute-X X)
	SBC-absolute-indexed (SBC-absolute-X X)
	ADC-absolute-indexed (ADC-absolute-Y Y)
	SBC-absolute-indexed (SBC-absolute-Y Y)

	ADC-indirect-X: function [
		/local pointer ZP-address address byte word
	][
		get-indirect-address-X
		ADC ((memory/read address))
	]
	SBC-indirect-X: function [
		/local pointer ZP-address address byte word
	][
		get-indirect-address-X
		SBC ((memory/read address))
	]

	ADC-indirect-Y: function [
		/local pointer ZP-address address byte word
	][
		get-indirect-address-Y
		ADC ((memory/read address))
	]
	SBC-indirect-Y: function [
		/local pointer ZP-address address byte word
	][
		get-indirect-address-Y
		SBC ((memory/read address))
	]

	branch (BCC (not  as-logic C and as-byte C-bit))
	branch (BCS (as-logic C and as-byte C-bit))
	branch (BEQ (not as-logic !Z))
	branch (BNE (as-logic !Z))
	branch (BPL (not  as-logic N and as-byte N-bit))
	branch (BMI (as-logic N and as-byte N-bit))
	; V is kept in the N position:
	branch (BVC (not  as-logic V and as-byte N-bit))
	branch (BVS (as-logic V and as-byte N-bit))

	JMP-absolute: function [
		/local byte-pointer word-pointer address
	][
		get-jump-address
		set-PC
	]
	JMP-indirect: function [
		/local byte-pointer word-pointer address
	][
		get-jump-address

		; Read order may be significant:
		address: (as word! memory/read address) or ((as word! memory/read address + 1) << 8)

		set-PC
	]

	JSR: function [
		/local byte-pointer word-pointer address
	][
		address: get-PC + 2 and FFFFh
		push-address

		get-jump-address
		set-PC
	]
	RTS: function [
		/local byte-pointer word-pointer address
	][
		either S = as-byte FEh [
			byte-pointer: stack + FFh
			address: (as word! stack/value) << 8 or (as word! byte-pointer/value) + 1 and FFFFh

			S: as-byte 0
		][
			word-pointer: as pointer! [word!] stack + as-integer S + 1
			address: word-pointer/value + 1 and FFFFh

			S: S + 2
		]
		set-PC
	]

	BRK: function [
		/local byte-pointer word-pointer address
	][
		address: get-PC + 1 and FFFFh  ; ?
		push-address

		push-status
		I: as-byte I-bit  ; ?
		B: as-byte B-bit

		jump-indirect (FFFEh)  ; IRQ vector
	]
	RTI: function [
		/local byte-pointer word-pointer address
	][
		pull-status

		either S = as-byte FEh [
			byte-pointer: stack + FFh
			address: (as word! stack/value) << 8 or as word! byte-pointer/value

			S: as-byte 0
		][
			word-pointer: as pointer! [word!] stack + as-integer S + 1
			address: word-pointer/value and FFFFh

			S: S + 2
		]
		set-PC

		if all [IRQ?  not as-logic I] [IRQ]
	]


	; Starting point

	begin: function [[typed]  "Initialise VM."
		count			[integer!]
		op-codes		[typed-value!]
	][
		; WARN: only valid while we stay in this function!
		instructions: op-codes

		reset
		do-events
	]

	begin [
		:BRK
		:ORA-indirect-X
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:ORA-ZP
		:ASL-ZP
		:illegal-op-code
		:PHP
		:ORA-immediate
		:ASL-A
		:illegal-op-code
		:illegal-op-code
		:ORA-absolute
		:ASL-absolute
		:illegal-op-code
		:BPL
		:ORA-indirect-Y
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:ORA-ZP-X
		:ASL-ZP-X
		:illegal-op-code
		:CLC
		:ORA-absolute-Y
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:ORA-absolute-X
		:ASL-absolute-X
		:illegal-op-code
		:JSR
		:AND-indirect-X
		:illegal-op-code
		:illegal-op-code
		:BIT-ZP
		:AND-ZP
		:ROL-ZP
		:illegal-op-code
		:PLP
		:AND-immediate
		:ROL-A
		:illegal-op-code
		:BIT-absolute
		:AND-absolute
		:ROL-absolute
		:illegal-op-code
		:BMI
		:AND-indirect-Y
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:AND-ZP-X
		:ROL-ZP-X
		:illegal-op-code
		:SEC
		:AND-absolute-Y
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:AND-absolute-X
		:ROL-absolute-X
		:illegal-op-code
		:RTI
		:EOR-indirect-X
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:EOR-ZP
		:LSR-ZP
		:illegal-op-code
		:PHA
		:EOR-immediate
		:LSR-A
		:illegal-op-code
		:JMP-absolute
		:EOR-absolute
		:LSR-absolute
		:illegal-op-code
		:BVC
		:EOR-indirect-Y
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:EOR-ZP-X
		:LSR-ZP-X
		:illegal-op-code
		:CLI
		:EOR-absolute-Y
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:EOR-absolute-X
		:LSR-absolute-X
		:illegal-op-code
		:RTS
		:ADC-indirect-X
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:ADC-ZP
		:ROR-ZP
		:illegal-op-code
		:PLA
		:ADC-immediate
		:ROR-A
		:illegal-op-code
		:JMP-indirect
		:ADC-absolute
		:ROR-absolute
		:illegal-op-code
		:BVS
		:ADC-indirect-Y
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:ADC-ZP-X
		:ROR-ZP-X
		:illegal-op-code
		:SEI
		:ADC-absolute-Y
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:ADC-absolute-X
		:ROR-absolute-X
		:illegal-op-code
		:illegal-op-code
		:STA-indirect-X
		:illegal-op-code
		:illegal-op-code
		:STY-ZP
		:STA-ZP
		:STX-ZP
		:illegal-op-code
		:DEY
		:illegal-op-code
		:TXA
		:illegal-op-code
		:STY-absolute
		:STA-absolute
		:STX-absolute
		:illegal-op-code
		:BCC
		:STA-indirect-Y
		:illegal-op-code
		:illegal-op-code
		:STY-ZP-X
		:STA-ZP-X
		:STX-ZP-Y
		:illegal-op-code
		:TYA
		:STA-absolute-Y
		:TXS
		:illegal-op-code
		:illegal-op-code
		:STA-absolute-X
		:illegal-op-code
		:illegal-op-code
		:LDY-immediate
		:LDA-indirect-X
		:LDX-immediate
		:illegal-op-code
		:LDY-ZP
		:LDA-ZP
		:LDX-ZP
		:illegal-op-code
		:TAY
		:LDA-immediate
		:TAX
		:illegal-op-code
		:LDY-absolute
		:LDA-absolute
		:LDX-absolute
		:illegal-op-code
		:BCS
		:LDA-indirect-Y
		:illegal-op-code
		:illegal-op-code
		:LDY-ZP-X
		:LDA-ZP-X
		:LDX-ZP-Y
		:illegal-op-code
		:CLV
		:LDA-absolute-Y
		:TSX
		:illegal-op-code
		:LDY-absolute-X
		:LDA-absolute-X
		:LDX-absolute-Y
		:illegal-op-code
		:CPY-immediate
		:CMP-indirect-X
		:illegal-op-code
		:illegal-op-code
		:CPY-ZP
		:CMP-ZP
		:DEC-ZP
		:illegal-op-code
		:INY
		:CMP-immediate
		:DEX
		:illegal-op-code
		:CPY-absolute
		:CMP-absolute
		:DEC-absolute
		:illegal-op-code
		:BNE
		:CMP-indirect-Y
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:CMP-ZP-X
		:DEC-ZP-X
		:illegal-op-code
		:CLD
		:CMP-absolute-Y
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:CMP-absolute-X
		:DEC-absolute-X
		:illegal-op-code
		:CPX-immediate
		:SBC-indirect-X
		:illegal-op-code
		:illegal-op-code
		:CPX-ZP
		:SBC-ZP
		:INC-ZP
		:illegal-op-code
		:INX
		:SBC-immediate
		:NOP
		:illegal-op-code
		:CPX-absolute
		:SBC-absolute
		:INC-absolute
		:illegal-op-code
		:BEQ
		:SBC-indirect-Y
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:SBC-ZP-X
		:INC-ZP-X
		:illegal-op-code
		:SED
		:SBC-absolute-Y
		:illegal-op-code
		:illegal-op-code
		:illegal-op-code
		:SBC-absolute-X
		:INC-absolute-X
		:illegal-op-code
	]

]
