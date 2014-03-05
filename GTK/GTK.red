Red [
	Title:		"GTK+ Binding"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2014 Kaj de Vos. All rights reserved."
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
		Red > 0.4.1
		GTK 2
		%common.red
		%GTK.reds
	}
	Tabs:		4
]


#include %../common/common.red

#system-global [#include %GTK.reds]


; Events

on-action: function ["Action callback"
	widget			[integer!]  "widget!"
	action			[integer!]
][
	switch/default action [
		2 [	; go
			do [go widget actions/2]
		]
	][
		set 'face widget
		do actions/:action
	]
]
#system [
	with gtk [
		on-action: function ["Action callback"
			[cdecl]
			face			[widget!]
			action			[integer!]
		][
			; Call back into Red
			stack/mark-func ~on-action
			integer/push as-integer face
			integer/push action
			f_on-action
			stack/unwind
			stack/reset
		]
	]
]


; Widgets

clear-face: routine ["Destroy face."
	face			[integer!]  "widget!"
][
	with gtk [clear-widget as widget! face]
]
show: routine ["Show face and all contained."
	face			[integer!]  "widget!"
][
	with gtk [show-all as widget! face]
]


make-label: routine ["Return a new label."
	text			[string!]
	return:			[integer!]  "label!"
	/local string face
][
	string: to-UTF8 text
	face: as-integer gtk/label string
	free-any string
	face
]


make-button: routine ["Return a new button."
	text			[string!]
	action			[integer!]
	return:			[integer!]  "button!"
	/local string face
][
	string: to-UTF8 text

	with gtk [
		face: as-integer switch action [
			0 [
				button string
			]
			1 [	; close
				button [string :quit]
			]
			default [
				button [string  :on-action as-handle action]
			]
		]
	]
	free-any string
	face
]
button?: routine ["Test for button type."
	face			[integer!]  "widget!"
	return:			[logic!]
][
	with gtk [gtk/button? as widget! face]
]
get-button-text: routine ["Get button label."
	button			[integer!]  "button!"
;	return:			[string!]
	/local			text
][
	with gtk [text: gtk/get-button-text as button! button]
	SET_RETURN ((string/load text  (length? text) + 1  UTF-8))
]


make-field: routine ["Return a new line entry field."
	text			[string!]
	action			[integer!]
	return:			[integer!]  "entry!"
	/local string face
][
	string: to-UTF8 text

	with gtk [
		face: as-integer switch action [
			0 [
				field string
			]
			1 [	; close
				field [string :quit]
			]
			default [
				field [string  :on-action as-handle action]
			]
		]
	]
	free-any string
	face
]
get-field-text: routine ["Get line entry field text."
	field			[integer!]  "entry!"
;	return:			[string!]
	/local			text
][
	with gtk [text: get-entry-text as entry! field]
	SET_RETURN ((string/load text  (length? text) + 1  UTF-8))
]


make-area: routine ["Return a new multi-line field."
	text			[string!]
	return:			[integer!]  "scrolled-window!"
	/local string face
][
	string: to-UTF8 text
	face: as-integer gtk/area string
	free-any string
	face
]
set-area-text: routine ["Set multi-line field text."
	area			[integer!]  "scrolled-window!"
	text			[string!]
	return:			[logic!]
	/local string ok?
][
	string: to-UTF8 text
	with gtk [ok?: gtk/set-area-text as scrolled-window! area  string]
	free-any string
	ok?
]
get-area-text: routine ["Get multi-line field text."
	area			[integer!]  "scrolled-window!"
;	return:			[string! none!]
	/local			text
][
	with gtk [text: gtk/get-area-text as scrolled-window! area]

	either as-logic text [
		SET_RETURN ((string/load text  (length? text) + 1  UTF-8))
;		g/g-free as-binary text
	][
		RETURN_NONE
	]
]


; Containers

make-window: routine ["Return a new window."
	title			[string!]
	return:			[integer!]  "window!"
	/local string face
][
	string: to-UTF8 title
	face: as-integer gtk/window string
	free-any string
	face
]


append-face: routine ["Add face to panel."
	panel			[integer!]  "container!"
	face			[integer!]  "widget!"
][
	with gtk [container-append  as container! panel  as widget! face]
]
remove-face: routine ["Remove face from panel."
	panel			[integer!]  "container!"
	face			[integer!]  "widget!"
][
	with gtk [container-remove  as container! panel  as widget! face]
]


make-hbox: routine ["Return a new horizontal box."
	return:			[integer!]  "box!"
][
	as-integer gtk/hbox no
]
make-vbox: routine ["Return a new vertical box."
	return:			[integer!]  "box!"
][
	as-integer gtk/vbox no
]
parse-hbox: function ["Return a new horizontal box."
	window			[integer!]  "window!"
	spec			[block!]
	return:			[integer!]  "box!"
][
	parse-box window make-hbox spec
]
parse-vbox: function ["Return a new vertical box."
	window			[integer! none!]  "window!"
	spec			[block!]
	return:			[integer!]  "box!"
][
	box: make-vbox
	parse-box any [window box] box spec
]
box-append: routine ["Add face to box."
	box				[integer!]  "box!"
	face			[integer!]  "widget!"
	expand?			[logic!]
	fill?			[logic!]
	padding			[integer!]  "unsigned!"
][
	with gtk [gtk/box-append  as box! box  as widget! face  expand? fill? padding]
]
parse-box: function ["Build box content."
	window			[integer!]  "window!"
	box				[integer!]  "box!"
	spec			[block!]
	return:			[integer!]  "box!"
][
	if zero? box [
		print "Box: missing box."
		return 0
	]
	assignee: none

	while [not tail? spec] [
		item: spec/1
		spec: next spec

		widget: none
		expand?: fill?: no

		switch/default type?/word item [
			word! [
				switch/default item [
					button [
						widget: make-button spec/1  ; Text
							switch/default type?/word action: spec/2 [
								word! [
									switch/default action [
										close [
											spec: next spec
											1
										]
										go [
											spec: next spec

											actions/2: window
											2
										]
									][
										0
									]
								]
								block! [
									spec: next spec

									append/only actions action
									length? actions
								]
							][
								0
							]
						spec: next spec
					]
					label [
						either string? text: spec/1 [
							widget: make-label text
							spec: next spec
						][
							print "Box: skipping LABEL: missing text."
						]
					]
					field [
						widget: make-field
							either string? text: spec/1 [
								spec: next spec
								text
							][
								""
							]
							switch/default type?/word action: spec/1 [
								word! [
									switch/default action [
										close [
											spec: next spec
											1
										]
										go [
											spec: next spec

											actions/2: window
											2
										]
									][
										0
									]
								]
								block! [
									spec: next spec

									append/only actions action
									length? actions
								]
							][
								0
							]
					]
					area [
						expand?: fill?: yes

						widget: make-area
							either string? text: spec/1 [
								spec: next spec
								text
							][
								""
							]
							switch/default type?/word action: spec/1 [
								block! [
									spec: next spec

									append/only actions action
									length? actions
								]
							][
								0
							]
					]
					hbox [
						either block? item: spec/1 [
							widget: parse-hbox window item
							spec: next spec
						][
							print "Box: skipping HBOX: missing block!"
						]
					]
					vbox [
						either block? item: spec/1 [
							widget: parse-vbox window item
							spec: next spec
						][
							print "Box: skipping VBOX: missing block!"
						]
					]
					fixed [
						either block? item: spec/1 [
							widget: parse-fixed window item
							spec: next spec
						][
							print "Box: skipping FIXED: missing block!"
						]
					]
				][
					prin ["Box: skipping unknown dialect word" mold form item] print #"."
				]
			]
			string! [
				widget: make-label item
			]
			set-word! [
				assignee: item
			]
			block! [
				widget: parse-hbox window item
			]
		][
			prin ["Box: skipping unknown element" form item] print #"."
		]
		if widget [
			either zero? widget [
				if assignee [set assignee none]

				print "Box: skipping missing widget."
			][
				if assignee [set assignee widget]

				box-append box widget expand? fill? 4
			]
			assignee: none
		]
	]
	box
]


make-fixed: routine ["Return a new fixed layout."
	return:			[integer!]  "fixed!"
	/local			fixed
][
	as-integer gtk/make-fixed
]
parse-fixed: function ["Return a new fixed layout."
	window			[integer!]  "window!"
	spec			[block!]
	return:			[integer!]  "fixed!"
][
	parse-box window make-fixed spec
]


view-only: routine ["Show a window."
	window			[integer!]  "window!"
	return:			[logic!]
][
	with gtk [gtk/view-only as window! window]
]
do-events: routine ["Start processing events."
][
	gtk/do-events
]
view: function ["Build and show a window."
	spec			[block! string!]
	/only			"Don't start event processing."
	/title
		text		[string!]
	return:			[integer! logic! none!]  "box!"
][
	unless block? spec [spec: reduce [spec]]

	all [
		not zero? window: make-window any [text  get-argument 0]
		not zero? box: parse-vbox none spec
		(
			append-face window box
			view-only window
		)
		either only [
			box
		][
			do-events
			yes
		]
	]
]


; Global setup

actions: [none none]  ; Dummies for CLOSE and GO
