Red/System [
	Title:		"GTK+ Binding"
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
		GTK 2
		%GDK.reds
	}
	Tabs:		4
]


#include %GDK.reds


with [gdk g] [gtk: context [

	#enum orientation! [horizontal vertical]

	#define allocation!				rectangle!

	requisition!: alias struct! [
		width						[integer!]
		height						[integer!]
	]

	style!:							alias opaque!

	object!: alias struct! [
	;	parent						[g-initially-unowned!]
			class					[g-type-class!]
			reference-count			[unsigned!]
	;		data					[g-data!]  ; TODO

		flags						[unsigned32!]
	]


	; Containers

	container!:						alias opaque!


	; Widgets

	widget!: alias struct! [
	;	object						[object!]
			class					[g-type-class!]
			reference-count			[unsigned!]
	;		data					[g-data!]  ; TODO
			flags					[unsigned32!]

	;	private-flags				[unsigned16!]
			private-flags-1			[byte!]
			private-flags-2			[byte!]
		state						[byte!]
		saved-state					[byte!]

		name						[c-string!]
		style						[style!]

	;	requisition					[requisition!]
			requested-width			[integer!]
			requested-height		[integer!]

	;	allocation					[allocation!]
			x						[integer!]
			y						[integer!]
			width					[integer!]
			height					[integer!]

		window						[gdk-window!]

		parent						[widget!]
	]


	; Windows

	window!:						alias opaque!

	#enum window-type! [window-top-level window-pop-up]

	#enum window-position! [
		position-none
		position-center
		position-mouse
		position-center-always
		position-center-on-parent
	]


	; Scrolled containers

	#enum shadow-type! [
		shadow-none
		shadow-in
		shadow-out
		shadow-etched-in
		shadow-etched-out
	]

	adjustment!:					alias opaque!
	scrolled-window!:				alias opaque!

	#enum policy-type! [
		policy-always
		policy-automatic
		policy-never
	]


	; Fixed layout

	fixed!:							alias opaque!


	; Box layout

	box!:							alias opaque!


	; Layout alignment

	alignment!:						alias opaque!


	; Tables

	table!:							alias opaque!

	#enum attach-options! [
		expand:						1
		shrink:						2
		fill:						4
	]


	; Labels

	label!:							alias opaque!


	; Buttons

	button!:						alias opaque!


	; Editables

	editable!:						alias opaque!


	; Line entry

	entry!:							alias opaque!
	entry-buffer!:					alias opaque!


	; Text buffers

	text-buffer!:					alias opaque!
	text-index!: alias struct! [
		dummy-1						[handle!]
		dummy-2						[handle!]
		dummy-3						[integer!]
		dummy-4						[integer!]
		dummy-5						[integer!]
		dummy-6						[integer!]
		dummy-7						[integer!]
		dummy-8						[integer!]
		dummy-9						[handle!]
		dummy-10					[handle!]
		dummy-11					[integer!]
		dummy-12					[integer!]
		dummy-13					[integer!]
		dummy-14					[handle!]
	]


	; Text views

	text-view!:						alias opaque!


	; Dialogs


	dialog!: alias struct! [
	;	window						[window!]  ; TODO

		vbox						[widget!]
		action-area					[widget!]

	;	separator					[widget!]  ; Private
	]


	; File selector

	file-chooser!:					alias opaque!

	file-chooser-dialog!: alias struct! [
	;	dialog						[dialog!]
	;		window					[window!]  ; TODO
			vbox					[widget!]
			action-area				[widget!]
			separator				[widget!]

	;	private						[file-chooser-dialog-private!]  ; TODO
	]

	#enum file-chooser-action! [
		action-open
		action-save
		action-select-folder
		action-make-folder
	]


	file-selection!: alias struct! [
	;	dialog						[dialog!]
	;		window					[window!]  ; TODO
			vbox					[widget!]
			action-area				[widget!]
			separator				[widget!]

		dir-list					[widget!]
		file-list					[widget!]
		selection-entry				[widget!]
		selection-text				[widget!]
		main-vbox					[widget!]
		ok-button					[widget!]
		cancel-button				[widget!]
		help-button					[widget!]
		history-pulldown			[widget!]
		history-menu				[widget!]
		history-list				[g-list!]
		file-op-dialog				[widget!]
		file-op-entry				[widget!]
		file-op-file				[c-string!]
		cmpl-state					[handle!]

		file-op-c-dir				[widget!]
		file-op-delete-file			[widget!]
		file-op-rename-file			[widget!]

		button-area					[widget!]
		action-area					[widget!]

	;	Private
	;	selected-names				[g-pointer-array!]  ; TODO
		last-selected				[c-string!]
	]


	#switch OS [
		Windows		[#define GTK-library "libgtk-win32-2.0-0.dll"]
		MacOSX		[#define GTK-library "libgtk-x11-2.0.dylib"]  ; TODO: check this
		#default	[#define GTK-library "libgtk-x11-2.0.so.0"]
	]
	#import [GTK-library cdecl [
		version-mismatch: "gtk_check_version" [								"Check GTK version."
			needed-major		[unsigned!]
			needed-minor		[unsigned!]
			needed-micro		[unsigned!]
			return:				[c-string!]
		]


		; Global setup

		begin: "gtk_init" [													"Set up GTK library."
			argc-reference		[pointer! [integer!]]
			argv-reference		[handle-reference!]							"Triple reference!"
		]


		; Events

		do-events: "gtk_main" [												"Enter event loop."
		]
		_quit: "gtk_main_quit" [											"Quit event loop."
		]


		; Containers

		container-append: "gtk_container_add" [								"Add widget to container."
			container			[container!]
			widget				[widget!]
		]
		container-remove: "gtk_container_remove" [							"Remove widget from container."
			container			[container!]
			widget				[widget!]
		]
		get-container-children: "gtk_container_get_children" [				"Get container children list."
			container			[container!]
			return:				[g-list!]
		]

		set-container-border: "gtk_container_set_border_width" [			"Set container border width."
			container			[container!]
			border				[unsigned!]
		]


		; Widgets

		widget-type: "gtk_widget_get_type" [								"Widget type."
			return:				[g-type!]
		]

		show: "gtk_widget_show" [											"Show widget."
			widget				[widget!]
		]
		show-all: "gtk_widget_show_all" [									"Show widget and all contained."
			widget				[widget!]
		]
		_clear-widget: "gtk_widget_destroy" [								"Clean up widget."
			widget				[widget!]
		]

		set-widget-size-request: "gtk_widget_set_size_request" [			"Request widget size."
			widget				[widget!]
			width				[integer!]
			height				[integer!]
		]


		; Windows

		make-window: "gtk_window_new" [										"Return new window."
			type				[window-type!]
			return:				[window!]
		]

		maximize-window: "gtk_window_maximize" [							"Maximise window."
			window				[window!]
		]
		unmaximize-window: "gtk_window_unmaximize" [						"Unmaximise window."
			window				[window!]
		]
		fullscreen-window: "gtk_window_fullscreen" [						"Make window fullscreen."
			window				[window!]
		]
		unfullscreen-window: "gtk_window_unfullscreen" [					"Make window not fullscreen."
			window				[window!]
		]
		set-window-position: "gtk_window_set_position" [					"Set window position."
			window				[window!]
			position			[window-position!]
		]
		set-window-size: "gtk_window_set_default_size" [					"Set window size."
			window				[window!]
			width				[integer!]
			height				[integer!]
		]
		set-window-resizable: "gtk_window_set_resizable" [					"Set window resizability."
			window				[window!]
			resizable?			[logic!]
		]

		set-window-title: "gtk_window_set_title" [							"Set window title."
			window				[window!]
			title				[c-string!]
		]
		set-window-icon: "gtk_window_set_icon" [							"Set window icon."
			window				[window!]
			icon				[image!]
		]


		; Scrolled containers

		make-scrolled-window: "gtk_scrolled_window_new" [					"Return new scrolled container."
			horizontal-adjust	[adjustment!]								"Optional"
			vertical-adjust		[adjustment!]								"Optional"
			return:				[scrolled-window!]
		]
		change-scrolled-window: "gtk_scrolled_window_add_with_viewport" [	"Add widget and implicit viewport to scrolled container."
			container			[scrolled-window!]
			widget				[widget!]
		]
		set-scrolled-window-policy: "gtk_scrolled_window_set_policy" [		"Set container scroll policy."
			container			[scrolled-window!]
			horizontal-policy	[policy-type!]
			vertical-policy		[policy-type!]
		]
		set-scrolled-window-shadow: "gtk_scrolled_window_set_shadow_type" [	"Set container shadow."
			container			[scrolled-window!]
			type				[shadow-type!]
		]


		; Fixed layout

		make-fixed: "gtk_fixed_new" [										"Return new fixed layout."
			return:				[fixed!]
		]
		add-fixed: "gtk_fixed_put" [										"Add widget to fixed layout."
			fixed				[fixed!]
			widget				[widget!]
			x					[integer!]
			y					[integer!]
		]


		; Box layouts

		make-box: "gtk_box_new" [											"Return new box layout."
			orientation			[orientation!]
			homogeneous?		[logic!]
			spacing				[integer!]
			return:				[box!]
		]
		make-hbox: "gtk_hbox_new" [											"Return new horizontal box layout."
			homogeneous?		[logic!]
			spacing				[integer!]
			return:				[box!]
		]
		make-vbox: "gtk_vbox_new" [											"Return new vertical box layout."
			homogeneous?		[logic!]
			spacing				[integer!]
			return:				[box!]
		]

		set-box-same: "gtk_box_set_homogeneous" [							"Set box layout homogeneousness."
			box					[box!]
			homogeneous?		[logic!]
		]
		_box-same?: "gtk_box_get_homogeneous" [								"Get box layout homogeneousness."
			box					[box!]
			return:				[g-logic!]
		]

		set-box-spacing: "gtk_box_set_spacing" [							"Set box layout spacing."
			box					[box!]
			spacing				[integer!]
		]
		get-box-spacing: "gtk_box_get_spacing" [							"Get box layout spacing."
			box					[box!]
			return:				[integer!]
		]

		box-append: "gtk_box_pack_start" [									"Add widget to box layout."
			box					[box!]
			widget				[widget!]
			expand?				[logic!]
			fill?				[logic!]
			padding				[unsigned!]
		]
		box-add-last: "gtk_box_pack_end" [									"Add last widget to box layout."
			box					[box!]
			widget				[widget!]
			expand?				[logic!]
			fill?				[logic!]
			padding				[unsigned!]
		]


		; Tables

		make-table: "gtk_table_new" [										"Return new table layout."
			rows				[unsigned!]
			columns				[unsigned!]
			homogeneous?		[logic!]
			return:				[table!]
		]
		resize-table: "gtk_table_resize" [									"Resize table dimensions."
			table				[table!]
			rows				[unsigned!]
			columns				[unsigned!]
		]

		set-table-same: "gtk_table_set_homogeneous" [						"Set table layout homogeneousness."
			table				[table!]
			homogeneous?		[logic!]
		]
		_table-same?: "gtk_table_get_homogeneous" [							"Get table layout homogeneousness."
			table				[table!]
			return:				[g-logic!]
		]

		set-rows-spacing: "gtk_table_set_row_spacings" [					"Set table rows spacing."
			table				[table!]
			spacing				[integer!]
		]
		set-columns-spacing: "gtk_table_set_col_spacings" [					"Set table columns spacing."
			table				[table!]
			spacing				[integer!]
		]

		change-table: "gtk_table_attach_defaults" [							"Set table cells."
			table				[table!]
			widget				[widget!]
			left				[unsigned!]
			right				[unsigned!]
			top					[unsigned!]
			bottom				[unsigned!]
		]
		change-table-with: "gtk_table_attach" [								"Set table cells with options."
			table				[table!]
			widget				[widget!]
			left				[unsigned!]
			right				[unsigned!]
			top					[unsigned!]
			bottom				[unsigned!]
			x-options			[attach-options!]
			y-options			[attach-options!]
			x-padding			[unsigned!]
			y-padding			[unsigned!]
		]


		; Labels

		make-label: "gtk_label_new" [										"Return new label."
			text				[c-string!]
			return:				[label!]
		]
		set-label-text: "gtk_label_set_text" [								"Set label text."
			label				[label!]
			text				[c-string!]
		]


		; Buttons

		button-type: "gtk_button_get_type" [								"Button type."
			return:				[g-type!]
		]

		make-button: "gtk_button_new" [										"Return new button."
			return:				[button!]
		]
		make-button-with-label: "gtk_button_new_with_label" [				"Return new button with text label."
			text				[c-string!]
			return:				[button!]
		]
		set-button-text: "gtk_button_set_label" [							"Set button label."
			button				[button!]
			text				[c-string!]
		]
		get-button-text: "gtk_button_get_label" [							"Get button label."
			button				[button!]
			return:				[c-string!]
		]


		; Editables

		set-editable: "gtk_editable_set_editable" [							"Set widget editability."
			widget				[editable!]
			editable?			[logic!]
		]


		; Line entry

		make-entry: "gtk_entry_new" [										"Return new line entry field."
			return:				[entry!]
		]

		set-entry-visibility: "gtk_entry_set_visibility" [					"Set line entry field input visibility."
			entry				[entry!]
			visible?			[logic!]
		]

		set-entry-width: "gtk_entry_set_width_chars" [						"Set entry field length."
			entry				[entry!]
			characters			[integer!]
		]
		set-max-entry: "gtk_entry_set_max_length" [							"Set maximum entry length."
			entry				[entry!]
			max					[integer!]
		]
		set-entry-text: "gtk_entry_set_text" [								"Set entry field text."
			entry				[entry!]
			text				[c-string!]
		]
		set-entry-buffer: "gtk_entry_set_buffer" [							"Set entry field buffer."
			entry				[entry!]
			buffer				[entry-buffer!]
		]
		get-entry-text: "gtk_entry_get_text" [								"Get entry field text."
			entry				[entry!]
			return:				[c-string!]
		]


		; Text buffers

		set-text-buffer-text: "gtk_text_buffer_set_text" [					"Set multi-line text."
			buffer				[text-buffer!]
			text				[c-string!]
			size				[integer!]
		]
		get-text-buffer-text: "gtk_text_buffer_get_text" [					"Extract multi-line text."
			buffer				[text-buffer!]
			start				[text-index!]
			end					[text-index!]
			include-hidden?		[logic!]
			return:				[c-string!]									"UTF-8"
		]

		get-text-buffer-bounds: "gtk_text_buffer_get_bounds" [				"Get multi-line text start and end positions."
			buffer				[text-buffer!]
			start				[text-index!]
			end					[text-index!]
		]


		; Text views

		make-text-view: "gtk_text_view_new" [								"Return new multi-line field."
			return:				[text-view!]
		]

		set-text-view-editable: "gtk_text_view_set_editable" [				"Set multi-line field editability."
			text-view			[text-view!]
			editable?			[logic!]
		]
		set-text-view-cursor: "gtk_text_view_set_cursor_visible" [			"Set multi-line field cursor visibility."
			text-view			[text-view!]
			cursor?				[logic!]
		]

		set-text-view-buffer: "gtk_text_view_set_buffer" [					"Set multi-line field buffer."
			text-view			[text-view!]
			buffer				[text-buffer!]
		]
		get-text-view-buffer: "gtk_text_view_get_buffer" [					"Get multi-line field buffer."
			text-view			[text-view!]
			return:				[text-buffer!]
		]


		; File selector

		make-file-chooser-dialog: "gtk_file_chooser_dialog_new" [			"Return file selector."
			[variadic]
			; title				[c-string!]
			; parent			[window!]
			; action			[file-chooser-action!]
			; first-button-text	[c-string!]
			; ...
			return:				[file-chooser-dialog!]
		]
		_get-file-name-choice: "gtk_file_chooser_get_filename" [			"Get selected file name."
			chooser				[file-chooser!]
			return:				[c-string!]
		]


		make-file-chooser: "gtk_file_selection_new" [						"Return file selector."
			title				[c-string!]
			return:				[widget!]
		]
		set-file-choice: "gtk_file_selection_set_filename" [				"Preselect file name."
			chooser				[file-selection!]
			file				[c-string!]
		]
		get-file-name-choice: "gtk_file_selection_get_filename" [			"Get selected file name."
			chooser				[file-selection!]
			return:				[c-string!]
		]
	]]


	; Higher level interface


	; Logging

	log-error: function ["Log GTK error."
		message				[c-string!]
	][
		print-line message
	]


	; Events

	quit: function [[cdecl]] [_quit]  ; Quit event loop.


	; Widgets

	widget?: function ["Test for widget type."
		instance			[g-object!]
		return:				[logic!]
	][
		any [
			all [as-logic instance/class  instance/class/type = widget-type]
			as-logic check-instance-type  as g-type-instance! instance  widget-type
		]
	]

	clear-widget: function [[cdecl]
		"Clean up widget."
		widget				[widget!]
	][
		_clear-widget widget
	]


	; Dialect constructors


	; Windows

	#define maximize	yes
	#define no-resize	no

	_window: function ["Build a window."
		count				[integer!]
		list				[typed-value!]
		return:				[window!]
		/local window type value
	][
		window: make-window window-top-level

		either as-logic window [
			set-container-border  as container! window  10
			connect-signal  as-handle window  "destroy"  as-integer :quit  null

			while [as-logic count] [
				type: list/type
				value: list/value

				count: count - 1
				list: list + 1

				case [
					type = type-integer! [
						either any [zero? count  list/type <> type-integer!] [
							set-window-position window value
						][
							set-window-size window value list/value

							count: count - 1
							list: list + 1
						]
					]
					type = system/alias/image! [
						either as-logic value [
							set-window-icon window  as image! value
						][
							log-error "Window: skipping missing icon."
						]
					]
					any-struct? type [
						either as-logic value [
							container-append  as container! window  as widget! value
						][
							log-error "Window: skipping missing widget."
						]
					]
					type = type-c-string! [
						either as-logic value [
							set-window-title window  as-c-string value
						][
							log-error "Window: skipping missing title."
						]
					]
					type = type-logic! [
						either as-logic value [
							set-container-border  as container! window  0
							maximize-window window
						][
							set-window-resizable window no
						]
					]
					yes [
						log-error "Window: skipping unknown element."
					]
				]
			]
		][
			log-error "Failed to create window."
		]
		window
	]

	window: function [[typed]
		"Build a window."
		count				[integer!]
		list				[typed-value!]
		return:				[window!]
	][
		_window count list
	]

	view-only: function [[typed]
		"Build and show a window."
		count				[integer!]
		list				[typed-value!]
		return:				[logic!]
		/local				window
	][
		window: as widget! either all [count = 1  list/type = system/alias/window!] [
			list/value
		][
			_window count list
		]
		either as-logic window [
			show-all window
			yes
		][
			log-error "No window to view."
			no
		]
	]
	view: function [[typed]
		"Build and show a window, start event loop."
		count				[integer!]
		list				[typed-value!]
		return:				[logic!]
		/local				window
	][
		window: as widget! either all [count = 1  list/type = system/alias/window!] [
			list/value
		][
			_window count list
		]
		either as-logic window [
			show-all window
			do-events
			yes
		][
			log-error "No window to view."
			no
		]
	]


	; Scrolled containers

	scroll: function [[typed]
		"Build a scrolled container."
		count				[integer!]
		list				[typed-value!]
		return:				[scrolled-window!]
		/local scroll type value
	][
		scroll: make-scrolled-window null null

		either as-logic scroll [
			set-scrolled-window-policy scroll policy-automatic policy-automatic

			while [as-logic count] [
				type: list/type
				value: list/value

				count: count - 1
				list: list + 1

				case [
					any-struct? type [
						either as-logic value [
							container-append  as container! scroll  as widget! value
						][
							log-error "Scrolled container: skipping missing widget."
						]
					]
					type = type-integer! [
						set-scrolled-window-shadow scroll value
					]
					yes [
						log-error "Scrolled container: skipping unknown element."
					]
				]
			]
		][
			log-error "Failed to create scrolled container."
		]
		scroll
	]


	; Fixed layout

	fixed: function [[typed]
		"Build a fixed layout."
		count				[integer!]
		list				[typed-value!]
		return:				[fixed!]
		/local layout type value x y
	][
		layout: make-fixed

		either as-logic layout [
			x: 0
			y: 0

			while [as-logic count] [
				type: list/type
				value: list/value

				count: count - 1
				list: list + 1

				case [
					type = type-integer! [
						either zero? count [
							log-error "Fixed layout: position without following widget."
						][
							either list/type = type-integer! [
								x: value
							][
								y: value
							]
						]
					]
					any-struct? type [
						either as-logic value [
							add-fixed layout  as widget! value  x y
						][
							log-error "Fixed layout: skipping missing widget."
						]
					]
					type = type-c-string! [
						either as-logic value [
							add-fixed layout  as widget! label as-c-string value  x y
						][
							log-error "Fixed layout: skipping missing text."
						]
					]
					yes [
						log-error "Fixed layout: skipping unknown element."
					]
				]
			]
		][
			log-error "Failed to create fixed layout."
		]
		layout
	]


	; Layout properties
	#define same			yes  ; Homogeneous cells


	; Box layouts

	; Segment properties
	#define full			yes
	#define wide			no  ; Expand

	box: function ["Build a box layout."
		box					[box!]
		count				[integer!]
		list				[typed-value!]
		/local type value expand? fill? padding
	][
		while [as-logic count] [
			type: list/type
			value: list/value

			count: count - 1
			list: list + 1

			case [
				any [any-struct? type  type = type-c-string!] [
					if type = type-c-string! [
						value: as-integer label as-c-string value
					]
					expand?: no
					fill?: no
					padding: 4

					while [all [as-logic count  not any [any-struct? list/type  list/type = type-c-string!]]] [
						type: list/type

						switch type [
							type-logic! [
								expand?: yes
								fill?: as-logic list/value
							]
							type-integer! [
								padding: list/value
							]
							default [
								log-error "Box layout child: skipping unknown element."
							]
						]
						count: count - 1
						list: list + 1
					]
					either as-logic value [
						box-append box  as widget! value  expand? fill? padding
					][
						log-error "Box layout: skipping missing widget."
					]
				]
				type = type-logic! [
					set-box-same box  as-logic value
				]
				type = type-integer! [
					set-box-spacing box value
				]
				yes [
					log-error "Box layout: skipping unknown element."
				]
			]
		]
	]

	hbox: function [[typed]
		"Build a horizontal box layout."
		count				[integer!]
		list				[typed-value!]
		return:				[box!]
		/local				widget
	][
		widget: make-hbox no 4

		either as-logic widget [
			box widget count list
		][
			log-error "Failed to create hbox layout."
		]
		widget
	]

	vbox: function [[typed]
		"Build a vertical box layout."
		count				[integer!]
		list				[typed-value!]
		return:				[box!]
		/local				widget
	][
		widget: make-vbox no 4

		either as-logic widget [
			box widget count list
		][
			log-error "Failed to create vbox layout."
		]
		widget
	]


	; Tables

	table: function [[typed]
		"Build a table layout."
		count				[integer!]
		list				[typed-value!]
		return:				[table!]
		/local table type value rows columns row column
	][
		either count < 2 [
			log-error "Table: rows and/or columns size missing."
			null
		][
			type: list/type
			columns: list/value

			count: count - 2
			list: list + 1

			either all [type = type-integer!  list/type = type-integer!] [
				rows: list/value
				list: list + 1

				table: make-table rows columns no

				either as-logic table [
					while [all [as-logic count  not any [any-struct? list/type  list/type = type-c-string!]]] [
						type: list/type
						value: list/value

						count: count - 1
						list: list + 1

						switch type [
							type-integer! [
								either list/type = type-integer! [
									set-columns-spacing table value
								][
									set-rows-spacing table value
								]
							]
							type-logic! [
								set-table-same table  as-logic value
							]
							default [
								log-error "Table: skipping unknown element."
							]
						]
					]

					row: 0

					while [row < rows] [
						column: 0

						while [column < columns] [
							if zero? count [return table]

							type: list/type
							value: list/value

							count: count - 1
							list: list + 1

							either any [any-struct? type  type = type-c-string!] [
								if type = type-c-string! [
									value: as-integer label as-c-string value
								]
								either as-logic value [
									change-table table  as widget! value
										column  column + 1
										row  row + 1
								][
									log-error "Table: skipping missing widget."
								]
							][
								log-error "Table: skipping unknown element."
							]
							column: column + 1
						]
						row: row + 1
					]

					if as-logic count [
						log-error "Table: skipping extra elements."
					]
				][
					log-error "Failed to create table layout."
				]
				table
			][
				log-error "Table: rows and/or columns size missing."
				null
			]
		]
	]


	; Labels

	label: function [[typed]
		"Build a label."
		count				[integer!]
		list				[typed-value!]
		return:				[label!]
		/local				label
	][
		label: make-label ""

		either as-logic label [
			while [as-logic count] [
				either list/type = type-c-string! [
					either as-logic list/value [
						set-label-text label  as-c-string list/value
					][
						log-error "Label: skipping missing text."
					]
				][
					log-error "Label: skipping unknown element."
				]
				count: count - 1
				list: list + 1
			]
		][
			log-error "Failed to create label."
		]
		label
	]


	; Icons

	icon: function ["Load an icon."
		file				[c-string!]
		return:				[image!]
		/local icon error-reference
	][
		error-reference: as g-error-reference! 0
		icon: load-image file error-reference

		unless as-logic icon [
;			TODO: join
			log-error "Icon: failed to load image file:"
			log-error file
;			FIXME: no error generated
;			log-error error-reference/value/message
;			g-free-error error-reference/value
		]
		icon
	]


	; Buttons

	button?: function ["Test for button type."
		instance			[widget!]
		return:				[logic!]
	][
		any [
			all [as-logic instance/class  instance/class/type = button-type]
			as-logic check-instance-type  as g-type-instance! instance  button-type
		]
	]

	button: function [[typed]
		"Build a button."
		count				[integer!]
		list				[typed-value!]
		return:				[button!]
		/local
			button
			data			[handle!]
			type value
	][
		button: make-button

		either as-logic button [
			while [as-logic count] [
				type: list/type
				value: list/value

				count: count - 1
				list: list + 1

				switch type [
					type-integer! [
						either any [zero? count  list/type <> type-integer!] [
							log-error "Button: skipping size without second number."
						][
							set-widget-size-request  as widget! button  value list/value

							count: count - 1
							list: list + 1
						]
					]
					type-c-string! [
						either as-logic value [
							set-button-text button  as-c-string value
						][
							log-error "Button: skipping missing label."
						]
					]
					type-function! [
						data: null

						if all [positive? count  any-struct? list/type] [
							data: as-handle list/value

							count: count - 1
							list: list + 1
						]
						either as-logic value [
							connect-signal  as-handle button  "clicked" value data
						][
							log-error "Button: skipping missing action."
						]
					]
					default [
						log-error "Button: skipping unknown element."
					]
				]
			]
		][
			log-error "Failed to create button."
		]
		button
	]


	; Line entry

	entry: function ["Build a line entry field."
		count				[integer!]
		list				[typed-value!]
		return:				[entry!]
		/local field data type value
	][
		field: make-entry

		either as-logic field [
			while [as-logic count] [
				type: list/type
				value: list/value

				count: count - 1
				list: list + 1

				switch type [
					type-integer! [
						set-entry-width field value
;						set-max-entry field value
					]
					type-c-string! [
						either as-logic value [
							set-entry-text field  as-c-string value
						][
							log-error "Line entry: skipping missing text."
						]
					]
					type-function! [
						either all [positive? count  any-struct? list/type] [
							data: as-handle list/value

							count: count - 1
							list: list + 1
						][
							data: as-handle field
						]
						either as-logic value [
							connect-signal  as-handle field  "activate" value data
						][
							log-error "Line entry: skipping missing action."
						]
					]
					default [
						either any-struct? type [
							either as-logic value [
								set-entry-buffer field  as entry-buffer! value
							][
								log-error "Line entry: skipping missing buffer."
							]
						][
							log-error "Line entry: skipping unknown element."
						]
					]
				]
			]
		][
			log-error "Failed to create line entry field."
		]
		field
	]

	field: function [[typed]
		"Build a line entry field."
		count				[integer!]
		list				[typed-value!]
		return:				[entry!]
	][
		entry count list
	]

	info: function [[typed]
		"Build a single-line text."
		count				[integer!]
		list				[typed-value!]
		return:				[entry!]
		/local				field
	][
		field: entry count list

		either as-logic field [
			set-editable  as editable! field  no
		][
			log-error "Failed to create info field."
		]
		field
	]

	secret: function [[typed]
		"Build a hidden line entry field."
		count				[integer!]
		list				[typed-value!]
		return:				[entry!]
		/local				field
	][
		field: entry count list

		either as-logic field [
			set-entry-visibility field  no
		][
			log-error "Failed to create secret entry field."
		]
		field
	]


	; Text views

	set-area-text: function ["Set multi-line field text."
		area				[scrolled-window!]
		text				[c-string!]  "UTF-8"
		return:				[logic!]
		/local list text-view buffer
	][
		list: get-container-children as container! area

		either as-logic list [
			text-view: list/data

			either as-logic text-view [
				buffer: get-text-view-buffer text-view

				either as-logic buffer [
					set-text-buffer-text buffer text  length? text
					yes
				][
					no
				]
			][
				no
			]
		][
			no
		]
	]
	get-area-text: function ["Extract multi-line field text."
		area				[scrolled-window!]
		return:				[c-string!]  "UTF-8"
		/local list text-view buffer start end
	][
		list: get-container-children as container! area

		either as-logic list [
			text-view: list/data

			either as-logic text-view [
				buffer: get-text-view-buffer text-view

				either as-logic buffer [
;					WARN: not thread safe
					start:	declare text-index!
					end:	declare text-index!

					get-text-buffer-bounds	buffer start end
					get-text-buffer-text	buffer start end no
				][
					null
				]
			][
				null
			]
		][
			null
		]
	]

	text-view: function ["Build a multi-line field."
		count				[integer!]
		list				[typed-value!]
		return:				[text-view!]
		/local text-view type value buffer
	][
		text-view: make-text-view

		either as-logic text-view [
			while [as-logic count] [
				type: list/type
				value: list/value

				case [
					type = type-c-string! [
						either as-logic value [
							buffer: get-text-view-buffer text-view

							either as-logic buffer [
								set-text-buffer-text
									buffer
									as-c-string value
									length? as-c-string value
							][
								log-error "Text view: failed to access text buffer."
							]
						][
							log-error "Text view: skipping missing text."
						]
					]
					any-struct? type [
						either as-logic value [
							set-text-view-buffer text-view  as text-buffer! value
						][
							log-error "Text view: skipping missing text buffer."
						]
					]
					yes [
						log-error "Text view: skipping unknown element."
					]
				]
				count: count - 1
				list: list + 1
			]
		][
			log-error "Failed to create multi-line text view."
		]
		text-view
	]

	area: function [[typed]
		"Build a multi-line field."
		count				[integer!]
		list				[typed-value!]
		return:				[scrolled-window!]
	][
		scroll [text-view count list  shadow-in]
	]

	text: function [[typed]
		"Build a multi-line text."
		count				[integer!]
		list				[typed-value!]
		return:				[text-view!]
		/local				view
	][
		view: text-view count list

		either as-logic view [
			set-text-view-editable	view no
			set-text-view-cursor	view no
		][
			log-error "Failed to create multi-line text."
		]
		view
	]


	; Dialogs


	; File selector

	file-chooser: function ["Build a file selector."
		title				[c-string!]
		parent				[window!]
		action				[file-chooser-action!]
		first-button-text	[c-string!]
		return:				[file-chooser-dialog!]
		/local				chooser
	][
		chooser: make-file-chooser-dialog title parent action first-button-text

		either as-logic chooser [
			connect-signal  as-handle chooser  "destroy"  as-integer :quit  null
		][
			log-error "Failed to create file chooser."
		]
		chooser
	]

	file-selector: function [[typed]
		"Build an old file selector."
		count				[integer!]
		list				[typed-value!]
		return:				[file-selection!]
		/local widget chooser type
	][
		widget: make-file-chooser ""

		either as-logic widget [
			chooser: as file-selection! widget

			connect-signal  as-handle chooser  "destroy"  as-integer :quit  null
			connect-signal-swapped
;				FIXME: file-selection! doesn't correctly identify cancel-button yet
				as-handle chooser/cancel-button
				"clicked"
				as-integer :clear-widget
				as-handle chooser

			while [as-logic count] [
				type: list/type

				either type = type-c-string! [
					either as-logic list/value [
						set-file-choice chooser  as-c-string list/value
					][
						log-error "File chooser: skipping missing file preselection."
					]
				][
					log-error "File chooser: skipping unknown element."
				]
				count: count - 1
				list: list + 1
			]
			chooser
		][
			log-error "Failed to create file chooser."
			null
		]
	]

]]


; Global setup

argc: system/args-count
argv-reference: declare handle-reference!
argv-reference/value: as-handle system/args-list

gtk/begin :argc argv-reference  ; Set up GTK library
