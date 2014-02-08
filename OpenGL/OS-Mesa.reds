Red/System [
	Title:		"OSMesa Binding"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2012,2013 Kaj de Vos. All rights reserved."
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
		%common/common.reds
		%OpenGL/GL-common.reds
	}
	Tabs:		4
]


#include %../common/common.reds


osmesa: context [with gl [

	osmesa-context!:		alias opaque!

	#enum pixel-store! [
		row-length':		10h
		y-up'
	]


	#import [OS-Mesa-library cdecl [

		; Off Screen rendering

		make-context: "OSMesaCreateContext" [
			format			[enum!]
			share-list		[osmesa-context!]
			return:			[osmesa-context!]
		]
		make-context-with: "OSMesaCreateContextExt" [
			format			[enum!]
			depth-bits		[integer!]
			stencil-bits	[integer!]
			accum-bits		[integer!]
			share-list		[osmesa-context!]
			return:			[osmesa-context!]
		]
		end-context: "OSMesaDestroyContext" [
			context			[osmesa-context!]
		]
		make-current: "OSMesaMakeCurrent" [
			context			[osmesa-context!]
			buffer			[binary!]
			type			[type!]
			width			[size!]
			height			[size!]
			return:			[logic!]
		]

		pixel-store: "OSMesaPixelStore" [
			name			[pixel-store!]
			value			[variant!]
		]

	]]
]]
