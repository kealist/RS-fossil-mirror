Red/System [
	Title:		"Java Virtual Machine binding"
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
		Red/System
		%Java/JNI.reds
	}
	Tabs:		4
]


#include %JNI.reds


JVM: context [with JNI [

	vm-double-reference!:			alias struct! [value [vm-reference!]]

	option!: alias struct! [
		option						[c-string!]
		data						[binary!]
	]
	begin-arguments!: alias struct! [
		version						[version!]
		option-count				[integer!]
		options						[option!]
		ignore-unknown?				[j-logic!]
	]

	#switch OS [
		Windows		[#define JVM-library "JVM.dll"]  ; TODO: check this
		MacOSX		[#define JVM-library "libjvm.dylib"]  ; TODO: check this
		#default	[#define JVM-library "libjvm.so"]
	]
	#import [JVM-library call! [

		get-default-arguments: "JNI_GetDefaultJavaVMInitArgs" [		"Get default arguments for a new Virtual Machine."
			arguments				[begin-arguments!]
			return:					[status!]
		]
		make-vm: "JNI_CreateJavaVM" [								"Create a new Virtual Machine."
			vm-double-reference		[vm-double-reference!]
			java-double-reference	[java-double-reference!]
			arguments				[begin-arguments!]
			return:					[status!]
		]
		get-VMs: "JNI_GetCreatedJavaVMs" [							"List Virtual Machines."
			vm-double-reference		[vm-double-reference!]
			size					[size!]
			count					[pointer! [size!]]
			return:					[status!]
		]

	]]
]]
