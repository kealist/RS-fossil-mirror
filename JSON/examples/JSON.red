Red [
	Title:		"JSON examples"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red >= 0.4.3
		%common/input-output.red
		%JSON.red
	}
	Tabs:		4
]

#include %../../common/input-output.red
#include %../JSON.red

print to-JSON			"Example"
probe load-JSON			{"Example"}
print to-JSON			{Controls: "\/^(line)^M^(tab)^(back)^(page)^(null)^(1F)}
probe load-JSON			{"Escapes: \"\\\/\n\r\t\b\f\u0000\u0020"}
print to-JSON			9
probe load-JSON			"9"
probe load-JSON			"6.28"
probe load-JSON/values	{["#issue", "%file", "{string}"]}
print to-JSON			[a 9 b]
print to-JSON			context [a: 9 b: 42]
print to-JSON/map		[a 9  b 42]
print to-JSON/map/deep	[a 9 [b 9  c 42]]
print to-JSON/map		[a 9  b [9]  c 42]
print to-JSON/flat/map	[a 9  b [9]  c 42]
probe load-JSON			{["a", 9, "bc", 42]}
probe load-JSON			{{"a": 9, "bc": 42}}
probe load-JSON/keys	{{"a": 9, "bc": 42}}
probe load-JSON/objects	{{"a": 9, "bc": 42}}
print to-JSON/flat		s: charset [#"0" - #"9"]
print to-JSON			complement s
print to-JSON/flat		blank
print to-JSON			charset [100 1000]

print headers: read http://headers.jsontest.com
print to-JSON/map probe load-JSON/keys headers
