Red/System [
	Title:		"C Math Library Binding"
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
		Red/System >= 0.3.2
		%common/FPU-configuration.reds
	}
	Tabs:		4
]


#include %../common/FPU-configuration.reds


#import [LIBM-file cdecl [
	fraction: "modf" [					"Integral and fractional parts"
		number		[float!]
		integral	[pointer! [float!]]
		return:		[float!]
	]

	round-ceiling: "ceil" [				"Smallest integer not less"
		number		[float!]
		return:		[float!]
	]
	round-floor: "floor" [				"Largest integer not greater"
		number		[float!]
		return:		[float!]
	]

	float-absolute: "fabs" [
		number		[float!]
		return:		[float!]
	]
	float-remainder: "fmod" [
		dividend	[float!]
		divisor		[float!]
		return:		[float!]
	]

	float-power: "pow" [				"Number raised to exponent"
		number		[float!]
		exponent	[float!]
		return:		[float!]
	]
	square-root: "sqrt" [
		number		[float!]
		return:		[float!]
	]

	exp: "exp" [						"Exponential"
		power		[float!]
		return:		[float!]
	]
	log-e: "log" [						"Natural logarithm"
		number		[float!]
		return:		[float!]
	]
	log-10: "log10" [					"Base 10 logarithm"
		number		[float!]
		return:		[float!]
	]

	sine-radians: "sin" [
		number		[float!]
		return:		[float!]
	]
	cosine-radians: "cos" [
		number		[float!]
		return:		[float!]
	]
	tangent-radians: "tan" [
		number		[float!]
		return:		[float!]
	]

	arcsine-radians: "asin" [
		number		[float!]
		return:		[float!]
	]
	arccosine-radians: "acos" [
		number		[float!]
		return:		[float!]
	]
	arctangent-radians: "atan" [
		number		[float!]
		return:		[float!]
	]
	arctangent-2-radians: "atan2" [
		y			[float!]
		x			[float!]
		return:		[float!]
	]

	hyper-sine-radians: "sinh" [		"Hyperbolic sine"
		number		[float!]
		return:		[float!]
	]
	hyper-cosine-radians: "cosh" [		"Hyperbolic cosine"
		number		[float!]
		return:		[float!]
	]
	hyper-tangent-radians: "tanh" [		"Hyperbolic tangent"
		number		[float!]
		return:		[float!]
	]

	ld-exp: "ldexp" [					"x * 2**n"
		significand	[float!]
		exponent	[integer!]
		return:		[float!]
	]
	fraction-exponent: "frexp" [		"Split into normalised fraction (significand) and power of 2."
		number		[float!]
		exponent	[pointer! [integer!]]
		return:		[float!]
	]
]]
