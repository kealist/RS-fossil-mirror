Red/System [
	Title:		"Java Native Interface library"
	Type:		'library
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
		Red/System >= 0.4.1
		%Java/JNI.reds
	}
	Tabs:		4
]


#include %JNI.reds


; Global setup

with JNI [
	JNI_OnLoad: function [
		vm-reference					[vm-reference!]
		dummy							[handle!]
		return:							[version!]
		/local status vm java-double-reference java-reference java
	][
		if none? vm-reference [return 0]

		vm: vm-reference/interface
		if none? vm [return 0]

		java-double-reference: declare java-double-reference!  ; WARN: not thread safe
		status: vm/get-context vm-reference java-double-reference version-1.6

		if negative? status [  ; Red/System FIXME: can't inline
			return 0  ; No use loading our library
		]
		java-reference: java-double-reference/value
		if none? java-reference [return 0]

		java: java-reference/interface
		if none? java [return 0]

		do-on-load (vm java-reference java)  ; User setup code

		version-1.6  ; Needed JNI version
	]
]

#export call! [JNI_OnLoad]
