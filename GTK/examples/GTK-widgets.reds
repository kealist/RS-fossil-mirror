Red/System [
	Title:		"GTK+ widgets overview"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011,2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Needs: {
		Red/System >= 0.3.1
		%GTK.reds
	}
	Tabs:		4
]

#include %../GTK.reds

with gtk [
	get-line: function [
		[cdecl]
		widget		[widget!]
		data		[entry!]
	][
		print ["Input: "  get-entry-text data  newline]
	]

	get-lines: function [
		[cdecl]
		widget		[widget!]
		data		[scrolled-window!]
		/local lines
	][
		lines: get-area-text data
		print ["Input: " lines newline]
		g/g-free as-binary lines
	]

	line: field [15 "Input Field" :get-line]

	lines: area
{Multi-line
input field.}

	view [
		position-center
		"Red/System Widgets Overview"
		icon "Red-48x48.png"
		vbox [
			"Vertical Box"
			hbox [
{Multi-line
label.}
				text
{Multi-line
text.}
				info [10 "Info"]
				scroll text "The long and scrolling road..."
			]
			hbox [
				"Horizontal Box"
				button "Tight"
				button "Expanded" wide
				button "Filled" full
			]
			hbox [
				vbox [
					"Vertical Box"
					button "Tight"
					button "Expanded" wide
					button "Filled" full
				] wide
				fixed [
					"Fixed Layout"
					5 25  button [50 25  "Quit" :quit]
				] wide
				vbox [
					"Table"
					table [2 2  5 5
						button "X"  button "O"
						button "O"  button "X"
					]
				] wide
			] full
			hbox [
				vbox [
					line
					fixed button [50 25  "Print"  :get-line line]
				]
				vbox [
					"Hidden Input"
					secret [10 "Secret" :get-line]
				]
				vbox [
					lines full
					fixed button [50 25  "Print"  :get-lines lines]
				] full
			] full
		]
	]
]
