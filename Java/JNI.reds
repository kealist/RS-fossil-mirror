Red/System [
	Title:		"Java Native Interface binding"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2013 Kaj de Vos. All rights reserved."
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
		Red/System > 0.3.2
		Java
		%common/common.reds
	}
	Tabs:		4
]


#include %../common/common.reds


#either OS = 'Windows [
	#define call! stdcall
][
	#define call! cdecl
]


JNI: context [

	; JNI versions

	#enum version! [
		version-1.1:					00010001h
		version-1.2:					00010002h
		version-1.4:					00010004h
		version-1.6:					00010006h
	]


	; Error handling

	#enum status! [
		status-ok

		error:							-1
		error-detached:					-2
		error-version:					-3
		error-memory:					-4
		error-vm-exists:				-5
		error-invalid:					-6
	]


	; Data types

	#define j-logic!					byte!

;	FIXME:
	#define char!						unsigned16!
	char-reference!:					alias struct! [value [char!]]

	; Object types

	object!:							alias opaque!
	class!:								alias opaque!
	weak!:								alias opaque!
	throwable!:							alias opaque!
	string!:							alias opaque!
	array!:								alias opaque!
	object-array!:						alias opaque!
	logic-array!:						alias opaque!
	byte-array!:						alias opaque!
	char-array!:						alias opaque!
	integer16-array!:					alias opaque!
	integer-array!:						alias opaque!
	integer64-array!:					alias opaque!
	float32-array!:						alias opaque!
	float64-array!:						alias opaque!

	#enum reference-type! [
		invalid-reference!
		local-reference!
		global-reference!
		weak-global-reference!
	]

	field!:								alias opaque!
	method!:							alias opaque!

	native-method!: alias struct! [
		name							[c-string!]
		signature						[c-string!]
;		function						[function!]
		function						[handle!]
	]

	; Dynamic type

	#define j-value!					integer64!
	value-array!:						alias struct! [item [integer64!]]


	; Arrays

	#enum release-mode! [
		release-done
		release-commit
		release-abort
	]


	; Forward references to function tables

	#define early-java-reference!		[struct! [interface [java!]]]
	#define early-vm-reference!			[struct! [interface [vm!]]]
	#define early-vm-double-reference!	[struct! [value [struct! [interface [handle!]]]]]


	; Per-thread native environment for the JNI interface

	java!: alias struct! [
		dummy1							[handle!]
		dummy2							[handle!]
		dummy3							[handle!]
		dummy4							[handle!]


		version-of [function! [									"GetVersion: return JNI version."
			[call!]
			context						[early-java-reference!]
			return:						[version!]
 		]]


		; Classes

		make-class [function! [									"DefineClass: return a new class."
			[call!]
			context						[early-java-reference!]
			name						[c-string!]
			loader						[object!]
			buffer						[binary!]
			size						[size!]
			return:						[class!]
 		]]
		find-class [function! [									"FindClass: search for class by name."
			[call!]
			context						[early-java-reference!]
			name						[c-string!]
			return:						[class!]
 		]]


		; Methods

		to-method [function! [									"FromReflectedMethod: return method ID from method object."
			[call!]
			context						[early-java-reference!]
			method						[object!]
			return:						[method!]
 		]]


		; Fields

		to-field [function! [									"FromReflectedField: return field ID from field object."
			[call!]
			context						[early-java-reference!]
			field						[object!]
			return:						[field!]
 		]]


		; Methods

		to-method-object [function! [							"ToReflectedMethod: return method object from method ID."
			[call!]
			context						[early-java-reference!]
			class						[class!]
			method						[method!]
			static?						[j-logic!]
			return:						[object!]
 		]]


		; Classes

		parent-class-of [function! [							"GetSuperclass: return parent class."
			[call!]
			context						[early-java-reference!]
			class						[class!]
			return:						[class!]
 		]]
		assignable-from? [function! [							"IsAssignableFrom: is sub-class assignable from super class?"
			[call!]
			context						[early-java-reference!]
			child						[class!]
			parent						[class!]
			return:						[j-logic!]
 		]]


		; Fields

		to-field-object [function! [							"ToReflectedField: return field object from field ID."
			[call!]
			context						[early-java-reference!]
			class						[class!]
			field						[field!]
			static?						[j-logic!]
			return:						[object!]
 		]]


		; Exceptions

		throw-exception [function! [							"Throw: throw exception."
			[call!]
			context						[early-java-reference!]
			throwable					[object!]
			return:						[status!]
 		]]
		throw-new [function! [									"ThrowNew: throw new exception."
			[call!]
			context						[early-java-reference!]
			class						[class!]
			message						[c-string!]
			return:						[status!]
 		]]

		exception-occurred [function! [							"ExceptionOccurred: exception occurred."
			[call!]
			context						[early-java-reference!]
			return:						[throwable!]
 		]]
		describe-exception [function! [							"ExceptionDescribe: describe exception."
			[call!]
			context						[early-java-reference!]
 		]]
		clear-exception [function! [							"ExceptionClear: clear exception."
			[call!]
			context						[early-java-reference!]
 		]]

		fatal-error [function! [								"FatalError: fatal error."
			[call!]
			context						[early-java-reference!]
			message						[c-string!]
 		]]

		push-frame [function! [									"PushLocalFrame: push local frame."
			[call!]
			context						[early-java-reference!]
			capacity					[integer!]
			return:						[status!]
 		]]
		pop-frame [function! [									"PopLocalFrame: pop local frame."
			[call!]
			context						[early-java-reference!]
			result						[object!]
			return:						[object!]
 		]]


		; Object references

		make-global-reference [function! [						"NewGlobalRef: return a new global reference."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			return:						[object!]
 		]]
		end-global-reference [function! [						"DeleteGlobalRef: delete global reference."
			[call!]
			context						[early-java-reference!]
			reference					[object!]
 		]]
		end-local-reference [function! [						"DeleteLocalRef: delete local reference."
			[call!]
			context						[early-java-reference!]
			reference					[object!]
 		]]

		same-object? [function! [								"IsSameObject: are objects the same?"
			[call!]
			context						[early-java-reference!]
			object-1					[object!]
			object-2					[object!]
			return:						[j-logic!]
 		]]

		make-local-reference [function! [						"NewLocalRef: return a new local reference."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			return:						[object!]
 		]]

		set-local-capacity [function! [							"EnsureLocalCapacity: ensure local capacity."
			[call!]
			context						[early-java-reference!]
			capacity					[integer!]
			return:						[status!]
 		]]


		; Objects

		allocate-object [function! [							"AllocObject: allocate a new object."
			[call!]
			context						[early-java-reference!]
			class						[class!]
			return:						[object!]
 		]]

		make-object [function! [								"NewObject: construct a new object with method."
			[call! variadic]
			; context					[early-java-reference!]
			; class						[class!]
			; method					[method!]
			;	...
			return:						[object!]
 		]]
		make-object-with [function! [							"NewObjectV: construct a new object with method and argument list."
			[call!]
			context						[early-java-reference!]
			class						[class!]
			method						[method!]
			arguments					[argument-list!]
			return:						[object!]
 		]]
		make-object-values [function! [							"NewObjectA: construct a new object with method and Java values list."
			[call!]
			context						[early-java-reference!]
			class						[class!]
			method						[method!]
			arguments					[value-array!]
			return:						[object!]
 		]]

		class-of [function! [									"GetObjectClass: return class of object."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			return:						[class!]
 		]]
		instance? [function! [									"IsAssignableFrom: is object an instance of class?"
			[call!]
			context						[early-java-reference!]
			object						[object!]
			class						[class!]
			return:						[j-logic!]
 		]]


		; Methods

		get-method [function! [									"GetMethodID: return named method ID from class."
			[call!]
			context						[early-java-reference!]
			class						[class!]
			name						[c-string!]
			signature					[c-string!]
			return:						[method!]
 		]]


		; Method calls

		do-object [function! [									"CallObjectMethod: return object from method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[object!]
 		]]
		do-object-with [function! [								"CallObjectMethodV: return object from method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[object!]
 		]]
		do-object-values [function! [							"CallObjectMethodA: return object from method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[object!]
 		]]

		do-logic [function! [									"CallBooleanMethod: return logic! from method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[j-logic!]
 		]]
		do-logic-with [function! [								"CallBooleanMethodV: return logic! from method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[j-logic!]
 		]]
		do-logic-values [function! [							"CallBooleanMethodA: return logic! from method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[j-logic!]
 		]]

		do-byte [function! [									"CallByteMethod: return byte from method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[byte!]
 		]]
		do-byte-with [function! [								"CallByteMethodV: return byte from method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[byte!]
 		]]
		do-byte-values [function! [								"CallByteMethodA: return byte from method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[byte!]
 		]]

		do-char [function! [									"CallCharMethod: return character from method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[char!]
 		]]
		do-char-with [function! [								"CallCharMethodV: return character from method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[char!]
 		]]
		do-char-values [function! [								"CallCharMethodA: return character from method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[char!]
 		]]

		do-integer16 [function! [								"CallShortMethod: return integer16! from method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[integer16!]
 		]]
		do-integer16-with [function! [							"CallShortMethodV: return integer16! from method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[integer16!]
 		]]
		do-integer16-values [function! [						"CallShortMethodA: return integer16! from method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[integer16!]
 		]]

		do-integer [function! [									"CallIntMethod: return integer from method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[integer!]
 		]]
		do-integer-with [function! [							"CallIntMethodV: return integer from method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[integer!]
 		]]
		do-integer-values [function! [							"CallIntMethodA: return integer from method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[integer!]
 		]]

		do-integer64 [function! [								"CallLongMethod: return integer64! from method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[integer64!]
 		]]
		do-integer64-with [function! [							"CallLongMethodV: return integer64! from method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[integer64!]
 		]]
		do-integer64-values [function! [						"CallLongMethodA: return integer64! from method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[integer64!]
 		]]

		do-float32 [function! [									"CallFloatMethod: return float32! from method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[float32!]
 		]]
		do-float32-with [function! [							"CallFloatMethodV: return float32! from method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[float32!]
 		]]
		do-float32-values [function! [							"CallFloatMethodA: return float32! from method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[float32!]
 		]]

		do-float64 [function! [									"CallDoubleMethod: return float64! from method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[float64!]
 		]]
		do-float64-with [function! [							"CallDoubleMethodV: return float64! from method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[float64!]
 		]]
		do-float64-values [function! [							"CallDoubleMethodA: return float64! from method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[float64!]
 		]]

		do-method [function! [									"CallVoidMethod: call method."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
 		]]
		do-method-with [function! [								"CallVoidMethodV: call method with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
 		]]
		do-method-values [function! [							"CallVoidMethodA: call method with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
 		]]


		; Non-virtual method calls

		do-non-virtual-object [function! [						"CallNonvirtualObjectMethod: return object from non-virtual method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[object!]
 		]]
		do-non-virtual-object-with [function! [					"CallNonvirtualObjectMethodV: return object from non-virtual method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[object!]
 		]]
		do-non-virtual-object-values [function! [				"CallNonvirtualObjectMethodA: return object from non-virtual method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[object!]
 		]]

		do-non-virtual-logic [function! [						"CallNonvirtualBooleanMethod: return logic! from non-virtual method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[j-logic!]
 		]]
		do-non-virtual-logic-with [function! [					"CallNonvirtualBooleanMethodV: return logic! from non-virtual method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[j-logic!]
 		]]
		do-non-virtual-logic-values [function! [				"CallNonvirtualBooleanMethodA: return logic! from non-virtual method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[j-logic!]
 		]]

		do-non-virtual-byte [function! [						"CallNonvirtualByteMethod: return byte from non-virtual method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[byte!]
 		]]
		do-non-virtual-byte-with [function! [					"CallNonvirtualByteMethodV: return byte from non-virtual method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[byte!]
 		]]
		do-non-virtual-byte-values [function! [					"CallNonvirtualByteMethodA: return byte from non-virtual method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[byte!]
 		]]

		do-non-virtual-char [function! [						"CallNonvirtualCharMethod: return character from non-virtual method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[char!]
 		]]
		do-non-virtual-char-with [function! [					"CallNonvirtualCharMethodV: return character from non-virtual method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[char!]
 		]]
		do-non-virtual-char-values [function! [					"CallNonvirtualCharMethodA: return character from non-virtual method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[char!]
 		]]

		do-non-virtual-integer16 [function! [					"CallNonvirtualShortMethod: return integer16! from non-virtual method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[integer16!]
 		]]
		do-non-virtual-integer16-with [function! [				"CallNonvirtualShortMethodV: return integer16! from non-virtual method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[integer16!]
 		]]
		do-non-virtual-integer16-values [function! [			"CallNonvirtualShortMethodA: return integer16! from non-virtual method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[integer16!]
 		]]

		do-non-virtual-integer [function! [						"CallNonvirtualIntMethod: return integer from non-virtual method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[integer!]
 		]]
		do-non-virtual-integer-with [function! [				"CallNonvirtualIntMethodV: return integer from non-virtual method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[integer!]
 		]]
		do-non-virtual-integer-values [function! [				"CallNonvirtualIntMethodA: return integer from non-virtual method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[integer!]
 		]]

		do-non-virtual-integer64 [function! [					"CallNonvirtualLongMethod: return integer64! from non-virtual method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[integer64!]
 		]]
		do-non-virtual-integer64-with [function! [				"CallNonvirtualLongMethodV: return integer64! from non-virtual method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[integer64!]
 		]]
		do-non-virtual-integer64-values [function! [			"CallNonvirtualLongMethodA: return integer64! from non-virtual method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[integer64!]
 		]]

		do-non-virtual-float32 [function! [						"CallNonvirtualFloatMethod: return float32! from non-virtual method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[float32!]
 		]]
		do-non-virtual-float32-with [function! [				"CallNonvirtualFloatMethodV: return float32! from non-virtual method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[float32!]
 		]]
		do-non-virtual-float32-values [function! [				"CallNonvirtualFloatMethodA: return float32! from non-virtual method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[float32!]
 		]]

		do-non-virtual-float64 [function! [						"CallNonvirtualDoubleMethod: return float64! from non-virtual method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[float64!]
 		]]
		do-non-virtual-float64-with [function! [				"CallNonvirtualDoubleMethodV: return float64! from non-virtual method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[float64!]
 		]]
		do-non-virtual-float64-values [function! [				"CallNonvirtualDoubleMethodA: return float64! from non-virtual method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[float64!]
 		]]

		do-non-virtual [function! [								"CallNonvirtualVoidMethod: call non-virtual method."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
 		]]
		do-non-virtual-with [function! [						"CallNonvirtualVoidMethodV: call non-virtual method with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
 		]]
		do-non-virtual-values [function! [						"CallNonvirtualVoidMethodA: call non-virtual method with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
 		]]


		; Fields

		get-field [function! [									"GetFieldID: return named field ID from class."
			[call!]
			context						[early-java-reference!]
			class						[class!]
			name						[c-string!]
			signature					[c-string!]
			return:						[field!]
 		]]


		; Field accessors

		get-object [function! [									"GetObjectField: return object from field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[object!]
 		]]
		get-logic [function! [									"GetBooleanField: return logic! from field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[j-logic!]
 		]]
		get-byte [function! [									"GetByteField: return byte from field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[byte!]
 		]]
		get-char [function! [									"GetCharField: return character from field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[char!]
 		]]
		get-integer16 [function! [								"GetShortField: return integer16! from field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[integer16!]
 		]]
		get-integer [function! [								"GetIntField: return integer from field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[integer!]
 		]]
		get-integer64 [function! [								"GetLongField: return integer64! from field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[integer64!]
 		]]
		get-float32 [function! [								"GetFloatField: return float32! from field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[float32!]
 		]]
		get-float64 [function! [								"GetDoubleField: return float64! from field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[float64!]
 		]]

		set-object [function! [									"SetObjectField: set object field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[object!]
 		]]
		set-logic [function! [									"SetBooleanField: set logic! field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[j-logic!]
 		]]
		set-byte [function! [									"SetByteField: set byte field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[byte!]
 		]]
		set-char [function! [									"SetCharField: set character field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[char!]
 		]]
		set-integer16 [function! [								"SetShortField: set integer16! field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[integer16!]
 		]]
		set-integer [function! [								"SetIntField: set integer field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[integer!]
 		]]
		set-integer64 [function! [								"SetLongField: set integer64! field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[integer64!]
 		]]
		set-float32 [function! [								"SetFloatField: set float32! field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[float32!]
 		]]
		set-float64 [function! [								"SetDoubleField: set float64! field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[float64!]
 		]]


		; Methods

		get-static-method [function! [							"GetStaticMethodID: return named static method ID from class."
			[call!]
			context						[early-java-reference!]
			class						[class!]
			name						[c-string!]
			signature					[c-string!]
			return:						[method!]
 		]]


		; Static method calls

		do-static-object [function! [							"CallStaticObjectMethod: return object from static method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[object!]
 		]]
		do-static-object-with [function! [						"CallStaticObjectMethodV: return object from static method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[object!]
 		]]
		do-static-object-values [function! [					"CallStaticObjectMethodA: return object from static method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[object!]
 		]]

		do-static-logic [function! [							"CallStaticBooleanMethod: return logic! from static method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[j-logic!]
 		]]
		do-static-logic-with [function! [						"CallStaticBooleanMethodV: return logic! from static method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[j-logic!]
 		]]
		do-static-logic-values [function! [						"CallStaticBooleanMethodA: return logic! from static method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[j-logic!]
 		]]

		do-static-byte [function! [								"CallStaticByteMethod: return byte from static method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[byte!]
 		]]
		do-static-byte-with [function! [						"CallStaticByteMethodV: return byte from static method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[byte!]
 		]]
		do-static-byte-values [function! [						"CallStaticByteMethodA: return byte from static method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[byte!]
 		]]

		do-static-char [function! [								"CallStaticCharMethod: return character from static method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[char!]
 		]]
		do-static-char-with [function! [						"CallStaticCharMethodV: return character from static method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[char!]
 		]]
		do-static-char-values [function! [						"CallStaticCharMethodA: return character from static method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[char!]
 		]]

		do-static-integer16 [function! [						"CallStaticShortMethod: return integer16! from static method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[integer16!]
 		]]
		do-static-integer16-with [function! [					"CallStaticShortMethodV: return integer16! from static method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[integer16!]
 		]]
		do-static-integer16-values [function! [					"CallStaticShortMethodA: return integer16! from static method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[integer16!]
 		]]

		do-static-integer [function! [							"CallStaticIntMethod: return integer from static method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[integer!]
 		]]
		do-static-integer-with [function! [						"CallStaticIntMethodV: return integer from static method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[integer!]
 		]]
		do-static-integer-values [function! [					"CallStaticIntMethodA: return integer from static method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[integer!]
 		]]

		do-static-integer64 [function! [						"CallStaticLongMethod: return integer64! from static method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[integer64!]
 		]]
		do-static-integer64-with [function! [					"CallStaticLongMethodV: return integer64! from static method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[integer64!]
 		]]
		do-static-integer64-values [function! [					"CallStaticLongMethodA: return integer64! from static method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[integer64!]
 		]]

		do-static-float32 [function! [							"CallStaticFloatMethod: return float32! from static method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[float32!]
 		]]
		do-static-float32-with [function! [						"CallStaticFloatMethodV: return float32! from static method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[float32!]
 		]]
		do-static-float32-values [function! [					"CallStaticFloatMethodA: return float32! from static method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[float32!]
 		]]

		do-static-float64 [function! [							"CallStaticDoubleMethod: return float64! from static method call."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
			return:						[float64!]
 		]]
		do-static-float64-with [function! [						"CallStaticDoubleMethodV: return float64! from static method call with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
			return:						[float64!]
 		]]
		do-static-float64-values [function! [					"CallStaticDoubleMethodA: return float64! from static method call with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
			return:						[float64!]
 		]]

		do-static [function! [									"CallStaticVoidMethod: call static method."
			[call! variadic]
			; context					[java-reference!]
			; object					[object!]
			; method					[method!]
			;	...
 		]]
		do-static-with [function! [								"CallStaticVoidMethodV: call static method with argument list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[argument-list!]
 		]]
		do-static-values [function! [							"CallStaticVoidMethodA: call static method with Java values list."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			method						[method!]
			arguments					[value-array!]
 		]]


		; Static fields

		get-static-field [function! [							"GetStaticFieldID: return named field ID from class."
			[call!]
			context						[early-java-reference!]
			class						[class!]
			name						[c-string!]
			signature					[c-string!]
			return:						[field!]
 		]]


		; Static field accessors

		get-static-object [function! [							"GetStaticObjectField: return object from static field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[object!]
 		]]
		get-static-logic [function! [							"GetStaticBooleanField: return logic! from static field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[j-logic!]
 		]]
		get-static-byte [function! [							"GetStaticByteField: return byte from static field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[byte!]
 		]]
		get-static-char [function! [							"GetStaticCharField: return character from static field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[char!]
 		]]
		get-static-integer16 [function! [						"GetStaticShortField: return integer16! from static field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[integer16!]
 		]]
		get-static-integer [function! [							"GetStaticIntField: return integer from static field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[integer!]
 		]]
		get-static-integer64 [function! [						"GetStaticLongField: return integer64! from static field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[integer64!]
 		]]
		get-static-float32 [function! [							"GetStaticFloatField: return float32! from static field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[float32!]
 		]]
		get-static-float64 [function! [							"GetStaticDoubleField: return float64! from static field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			return:						[float64!]
 		]]

		set-static-object [function! [							"SetStaticObjectField: set static object field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[object!]
 		]]
		set-static-logic [function! [							"SetStaticBooleanField: set static logic! field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[j-logic!]
 		]]
		set-static-byte [function! [							"SetStaticByteField: set static byte field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[byte!]
 		]]
		set-static-char [function! [							"SetStaticCharField: set static character field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[char!]
 		]]
		set-static-integer16 [function! [						"SetStaticShortField: set static integer16! field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[integer16!]
 		]]
		set-static-integer [function! [							"SetStaticIntField: set static integer field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[integer!]
 		]]
		set-static-integer64 [function! [						"SetStaticLongField: set static integer64! field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[integer64!]
 		]]
		set-static-float32 [function! [							"SetStaticFloatField: set static float32! field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[float32!]
 		]]
		set-static-float64 [function! [							"SetStaticDoubleField: set static float64! field."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			field						[field!]
			value						[float64!]
 		]]


		; Strings

		make-string [function! [								"NewString: return a new string."
			[call!]
			context						[early-java-reference!]
			unicode						[char-reference!]
			length						[size!]
			return:						[string!]
 		]]
		string-length-of [function! [							"GetStringLength: return string length."
			[call!]
			context						[early-java-reference!]
			string						[string!]
			return:						[size!]
 		]]
		string-chars-of [function! [							"GetStringChars: return string characters."
			[call!]
			context						[early-java-reference!]
			string						[string!]
			copy?						[j-logic!]
			return:						[char-reference!]
 		]]
		release-string [function! [								"ReleaseStringChars: release string characters."
			[call!]
			context						[early-java-reference!]
			string						[string!]
			characters					[char-reference!]
 		]]

		make-utf-string [function! [							"NewStringUTF: return a new UTF string."
			[call!]
			context						[early-java-reference!]
			utf							[c-string!]
			return:						[string!]
 		]]
		utf-length-of [function! [								"GetStringUTFLength: return UTF string length."
			[call!]
			context						[early-java-reference!]
			string						[string!]
			return:						[size!]
 		]]
		utf-chars-of [function! [								"GetStringUTFChars: return UTF string characters."
			[call!]
			context						[early-java-reference!]
			string						[string!]
			copy?						[j-logic!]
			return:						[c-string!]
 		]]
		release-utf [function! [								"ReleaseStringUTFChars: release UTF string characters."
			[call!]
			context						[early-java-reference!]
			string						[string!]
			characters					[c-string!]
 		]]


		; Arrays

		array-length-of [function! [							"GetArrayLength: return array length."
			[call!]
			context						[early-java-reference!]
			array						[array!]
			return:						[size!]
 		]]

		make-object-array [function! [							"NewObjectArray: return a new object array."
			[call!]
			context						[early-java-reference!]
			length						[size!]
			class						[class!]
			template					[object!]
			return:						[object-array!]
 		]]


		; Array accessors

		pick-object [function! [								"GetObjectArrayElement: return indexed element from object array."
			[call!]
			context						[early-java-reference!]
			array						[object-array!]
			index						[size!]
			return:						[object!]
 		]]
		poke-object [function! [								"SetObjectArrayElement: set indexed element in object array."
			[call!]
			context						[early-java-reference!]
			array						[object-array!]
			index						[size!]
			value						[object!]
 		]]


		; Arrays

		make-logic-array [function! [							"NewBooleanArray: return a new logic! array."
			[call!]
			context						[early-java-reference!]
			length						[size!]
			return:						[logic-array!]
 		]]
		make-byte-array [function! [							"NewByteArray: return a new byte array."
			[call!]
			context						[early-java-reference!]
			length						[size!]
			return:						[byte-array!]
 		]]
		make-char-array [function! [							"NewCharArray: return a new character array."
			[call!]
			context						[early-java-reference!]
			length						[size!]
			return:						[char-array!]
 		]]
		make-integer16-array [function! [						"NewShortArray: return a new integer16! array."
			[call!]
			context						[early-java-reference!]
			length						[size!]
			return:						[integer16-array!]
 		]]
		make-integer-array [function! [							"NewIntArray: return a new integer array."
			[call!]
			context						[early-java-reference!]
			length						[size!]
			return:						[integer-array!]
 		]]
		make-integer64-array [function! [						"NewLongArray: return a new integer64! array."
			[call!]
			context						[early-java-reference!]
			length						[size!]
			return:						[integer64-array!]
 		]]
		make-float32-array [function! [							"NewFloatArray: return a new float32! array."
			[call!]
			context						[early-java-reference!]
			length						[size!]
			return:						[float32-array!]
 		]]
		make-float64-array [function! [							"NewDoubleArray: return a new float64! array."
			[call!]
			context						[early-java-reference!]
			length						[size!]
			return:						[float64-array!]
 		]]


		; Array accessors

		logics-of [function! [									"GetBooleanArrayElements: return logic! array elements."
			[call!]
			context						[early-java-reference!]
			array						[logic-array!]
			copy?						[j-logic!]
			return:						[pointer! [j-logic!]]
 		]]
		bytes-of [function! [									"GetByteArrayElements: return byte array elements."
			[call!]
			context						[early-java-reference!]
			array						[byte-array!]
			copy?						[j-logic!]
			return:						[binary!]
 		]]
		chars-of [function! [									"GetCharArrayElements: return character array elements."
			[call!]
			context						[early-java-reference!]
			array						[char-array!]
			copy?						[j-logic!]
			return:						[char-reference!]
 		]]
		integer16s-of [function! [								"GetShortArrayElements: return integer16! array elements."
			[call!]
			context						[early-java-reference!]
			array						[integer16-array!]
			copy?						[j-logic!]
			return:						[integer16-reference!]
 		]]
		integers-of [function! [								"GetIntArrayElements: return integer array elements."
			[call!]
			context						[early-java-reference!]
			array						[integer-array!]
			copy?						[j-logic!]
			return:						[pointer! [integer!]]
 		]]
		integer64s-of [function! [								"GetLongArrayElements: return integer64! array elements."
			[call!]
			context						[early-java-reference!]
			array						[integer64-array!]
			copy?						[j-logic!]
			return:						[pointer! [integer64!]]
 		]]
		float32s-of [function! [								"GetFloatArrayElements: return float32! array elements."
			[call!]
			context						[early-java-reference!]
			array						[float32-array!]
			copy?						[j-logic!]
			return:						[pointer! [float32!]]
 		]]
		float64s-of [function! [								"GetDoubleArrayElements: return float64! array elements."
			[call!]
			context						[early-java-reference!]
			array						[float64-array!]
			copy?						[j-logic!]
			return:						[pointer! [float64!]]
 		]]


		; Array operations

		release-logics [function! [								"ReleaseBooleanArrayElements: release logic! array elements."
			[call!]
			context						[early-java-reference!]
			array						[logic-array!]
			elements					[pointer! [j-logic!]]
			mode						[release-mode!]
 		]]
		release-bytes [function! [								"ReleaseByteArrayElements: release byte array elements."
			[call!]
			context						[early-java-reference!]
			array						[byte-array!]
			elements					[binary!]
			mode						[release-mode!]
 		]]
		release-chars [function! [								"ReleaseCharArrayElements: release character array elements."
			[call!]
			context						[early-java-reference!]
			array						[char-array!]
			elements					[char-reference!]
			mode						[release-mode!]
 		]]
		release-integer16s [function! [							"ReleaseShortArrayElements: release integer16! array elements."
			[call!]
			context						[early-java-reference!]
			array						[integer16-array!]
			elements					[integer16-reference!]
			mode						[release-mode!]
 		]]
		release-integers [function! [							"ReleaseIntArrayElements: release integer array elements."
			[call!]
			context						[early-java-reference!]
			array						[integer-array!]
			elements					[pointer! [integer!]]
			mode						[release-mode!]
 		]]
		release-integer64s [function! [							"ReleaseLongArrayElements: release integer64! array elements."
			[call!]
			context						[early-java-reference!]
			array						[integer64-array!]
			elements					[pointer! [integer64!]]
			mode						[release-mode!]
 		]]
		release-float32s [function! [							"ReleaseFloatArrayElements: release float32! array elements."
			[call!]
			context						[early-java-reference!]
			array						[float32-array!]
			elements					[pointer! [float32!]]
			mode						[release-mode!]
 		]]
		release-float64s [function! [							"ReleaseDoubleArrayElements: release float64! array elements."
			[call!]
			context						[early-java-reference!]
			array						[float64-array!]
			elements					[pointer! [float64!]]
			mode						[release-mode!]
 		]]

		copy-logics [function! [								"GetBooleanArrayRegion: copy logic! array region."
			[call!]
			context						[early-java-reference!]
			array						[logic-array!]
			index						[size!]
			length						[size!]
			into						[pointer! [j-logic!]]
 		]]
		copy-bytes [function! [									"GetByteArrayRegion: copy byte array region."
			[call!]
			context						[early-java-reference!]
			array						[byte-array!]
			index						[size!]
			length						[size!]
			into						[binary!]
 		]]
		copy-chars [function! [									"GetCharArrayRegion: copy character array region."
			[call!]
			context						[early-java-reference!]
			array						[char-array!]
			index						[size!]
			length						[size!]
			into						[char-reference!]
 		]]
		copy-integer16s [function! [							"GetShortArrayRegion: copy integer16! array region."
			[call!]
			context						[early-java-reference!]
			array						[integer16-array!]
			index						[size!]
			length						[size!]
			into						[integer16-reference!]
 		]]
		copy-integers [function! [								"GetIntArrayRegion: copy integer array region."
			[call!]
			context						[early-java-reference!]
			array						[integer-array!]
			index						[size!]
			length						[size!]
			into						[pointer! [integer!]]
 		]]
		copy-integer64s [function! [							"GetLongArrayRegion: copy integer64! array region."
			[call!]
			context						[early-java-reference!]
			array						[integer64-array!]
			index						[size!]
			length						[size!]
			into						[pointer! [integer64!]]
 		]]
		copy-float32s [function! [								"GetFloatArrayRegion: copy float32! array region."
			[call!]
			context						[early-java-reference!]
			array						[float32-array!]
			index						[size!]
			length						[size!]
			into						[pointer! [float32!]]
 		]]
		copy-float64s [function! [								"GetDoubleArrayRegion: copy float64! array region."
			[call!]
			context						[early-java-reference!]
			array						[float64-array!]
			index						[size!]
			length						[size!]
			into						[pointer! [float64!]]
 		]]

		change-logics [function! [								"SetBooleanArrayRegion: change logic! array region."
			[call!]
			context						[early-java-reference!]
			array						[logic-array!]
			index						[size!]
			length						[size!]
			elements					[pointer! [j-logic!]]
 		]]
		change-bytes [function! [								"SetByteArrayRegion: change byte array region."
			[call!]
			context						[early-java-reference!]
			array						[byte-array!]
			index						[size!]
			length						[size!]
			elements					[binary!]
 		]]
		change-chars [function! [								"SetCharArrayRegion: change character array region."
			[call!]
			context						[early-java-reference!]
			array						[char-array!]
			index						[size!]
			length						[size!]
			elements					[char-reference!]
 		]]
		change-integer16s [function! [							"SetShortArrayRegion: change integer16! array region."
			[call!]
			context						[early-java-reference!]
			array						[integer16-array!]
			index						[size!]
			length						[size!]
			elements					[integer16-reference!]
 		]]
		change-integers [function! [							"SetIntArrayRegion: change integer array region."
			[call!]
			context						[early-java-reference!]
			array						[integer-array!]
			index						[size!]
			length						[size!]
			elements					[pointer! [integer!]]
 		]]
		change-integer64s [function! [							"SetLongArrayRegion: change integer64! array region."
			[call!]
			context						[early-java-reference!]
			array						[integer64-array!]
			index						[size!]
			length						[size!]
			elements					[pointer! [integer64!]]
 		]]
		change-float32s [function! [							"SetFloatArrayRegion: change float32! array region."
			[call!]
			context						[early-java-reference!]
			array						[float32-array!]
			index						[size!]
			length						[size!]
			elements					[pointer! [float32!]]
 		]]
		change-float64s [function! [							"SetDoubleArrayRegion: change float64! array region."
			[call!]
			context						[early-java-reference!]
			array						[float64-array!]
			index						[size!]
			length						[size!]
			elements					[pointer! [float64!]]
 		]]


		; Native methods

		register-natives [function! [							"RegisterNatives: register native methods."
			[call!]
			context						[early-java-reference!]
			class						[class!]
			methods						[native-method!]
			count						[integer!]
			return:						[status!]
 		]]
		unregister-natives [function! [							"UnregisterNatives: unregister native methods."
			[call!]
			context						[early-java-reference!]
			class						[class!]
			return:						[status!]
 		]]


		; System functions

		monitor [function! [									"MonitorEnter: start monitoring object."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			return:						[status!]
 		]]
		quit-monitor [function! [								"MonitorExit: stop monitoring object."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			return:						[status!]
 		]]

		get-vm [function! [										"GetJavaVM: get Virtual Machine context."
			[call!]
			context						[early-java-reference!]
			vm-double-reference			[early-vm-double-reference!]
			return:						[status!]
 		]]


		; Strings

		copy-string [function! [								"GetStringRegion: copy string region."
			[call!]
			context						[early-java-reference!]
			string						[string!]
			index						[size!]
			length						[size!]
			into						[char-reference!]
 		]]
		copy-utf [function! [									"GetStringUTFRegion: copy UTF string region."
			[call!]
			context						[early-java-reference!]
			string						[string!]
			index						[size!]
			length						[size!]
			into						[c-string!]
 		]]


		; Critical operations

		get-critical-array [function! [							"GetPrimitiveArrayCritical: return critical raw bytes array content."
			[call!]
			context						[early-java-reference!]
			array						[array!]
			copy?						[j-logic!]
			return:						[binary!]
 		]]
		release-critical-array [function! [						"ReleasePrimitiveArrayCritical: release critical raw bytes array content."
			[call!]
			context						[early-java-reference!]
			array						[array!]
			content						[binary!]
			mode						[release-mode!]
 		]]

		get-critical-string [function! [						"GetStringCritical: return critical raw bytes string content."
			[call!]
			context						[early-java-reference!]
			string						[string!]
			copy?						[j-logic!]
			return:						[char-reference!]
 		]]
		release-critical-string [function! [					"ReleaseStringCritical: release critical raw bytes string content."
			[call!]
			context						[early-java-reference!]
			string						[string!]
			elements					[char-reference!]
 		]]


		; Object references

		make-weak-global-reference [function! [					"NewWeakGlobalRef: return a new weak global reference."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			return:						[weak!]
 		]]
		end-weak-global-reference [function! [					"DeleteWeakGlobalRef: delete weak global reference."
			[call!]
			context						[early-java-reference!]
			reference					[weak!]
 		]]


		; Exceptions

		check-exception [function! [							"ExceptionCheck: check exception."
			[call!]
			context						[early-java-reference!]
			return:						[j-logic!]
 		]]


		; Binary buffers

		make-binary [function! [								"NewDirectByteBuffer: return a new binary."
			[call!]
			context						[early-java-reference!]
			address						[binary!]
			size						[integer64!]
			return:						[object!]
 		]]
		binary-of [function! [									"GetDirectBufferAddress: return binary bytes."
			[call!]
			context						[early-java-reference!]
			buffer						[object!]
			return:						[binary!]
 		]]
		binary-size-of [function! [								"GetDirectBufferCapacity: return binary size."
			[call!]
			context						[early-java-reference!]
			buffer						[object!]
			return:						[integer64!]
 		]]


		; JNI 1.6

		; Object references

		reference-type-of [function! [							"GetObjectRefType: return object reference type."
			[call!]
			context						[early-java-reference!]
			object						[object!]
			return:						[reference-type!]
 		]]
	]

	java-reference!:					alias early-java-reference!
	java-double-reference!:				alias struct! [value [java-reference!]]


	; JNI interface to the Java Virtual Machine

	attach-arguments!: alias struct! [
		version							[version!]
		name							[c-string!]
		group							[object!]
	]

	vm!: alias struct! [
		dummy1							[handle!]
		dummy2							[handle!]
		dummy3							[handle!]

		end-vm [function! [										"DestroyJavaVM: destroy Virtual Machine."
			[call!]
			vm-reference				[early-vm-reference!]
			return:						[status!]
 		]]

		attach-thread [function! [								"AttachCurrentThread: attach current thread."
			[call!]
			vm-reference				[early-vm-reference!]
			java-double-reference		[java-double-reference!]
			arguments					[attach-arguments!]
			return:						[status!]
 		]]
		detach-thread [function! [								"DetachCurrentThread: detach current thread."
			[call!]
			vm-reference				[early-vm-reference!]
			return:						[status!]
 		]]

		get-context [function! [								"GetEnv: get JNI thread environment."
			[call!]
			vm-reference				[early-vm-reference!]
			java-double-reference		[java-double-reference!]
			version						[version!]
			return:						[status!]
 		]]

		demonize-thread [function! [							"AttachCurrentThreadAsDaemon: attach current thread as daemon."
			[call!]
			vm-reference				[early-vm-reference!]
			java-double-reference		[java-double-reference!]
			arguments					[attach-arguments!]
			return:						[status!]
 		]]
	]

	vm-reference!:						alias early-vm-reference!

]
