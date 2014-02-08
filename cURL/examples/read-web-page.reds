Red/System [
	Title:		"cURL example: reading a web page"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red/System >= 0.3.1
		%cURL.reds
	}
	Purpose: {
		Show how to read a network URL with the cURL binding for Red/System.
	}
	Tabs:		4
]


#include %../cURL.reds


argument: get-argument 1
text: as-c-string 0

either none? argument [
	argument: get-argument 0
	print-line [
		"Usage: " argument " <URL>" newline
		"cURL version: " curl/version
	]
][
	text: read-url argument

	either none? text [
		print-line "Failed to read URL"
	][
		print-line text
		free-any text
	]
]
end-argument argument
