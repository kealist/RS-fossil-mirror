Red [
	Title:		"Tagged NetStrings examples"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2013,2014 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		%C-library/input-output.red
		%TNetStrings.red
	}
	Tabs:		4
]

#include %../../C-library/input-output.red
#include %../TNetStrings.red

print to-TNetString				"Example"
probe load-TNetString			"7:Example,"
print to-TNetString/only		[9]
probe load-TNetString/all		"1:9#"
probe load-TNetString			"4:6.28^^"  ; Red FIXME
probe load-TNetString/values	{6:#issue,5:%file,8:"string",}
print to-TNetString				context [a: 9 b: 42]
print to-TNetString/map			[a 9  b 42]
probe load-TNetString			"17:1:a,1:9#1:b,2:42#}"
probe load-TNetString/keys		"17:1:a,1:9#1:b,2:42#}"
probe load-TNetString/objects	"17:1:a,1:9#1:b,2:42#}"
print to-TNetString				s: charset [#"0" - #"9"]
print to-TNetString				complement s
print to-TNetString				charset [100 1000]
