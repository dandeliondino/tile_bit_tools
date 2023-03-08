@tool
extends Node

const UNASSIGNED := -1

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
const Context := preload("res://addons/tile_bit_tools/core/context.gd")

var _print := preload("res://addons/tile_bit_tools/core/print.gd").new()

var context : Context
var category_control_height := UNASSIGNED


# TODO: add request_apply_style for styling runtime generated controls

func _tiles_inspector_added(p_context : Context) -> void:
	context = p_context
	await get_tree().process_frame
	_update_themes()


func _tiles_inspector_removed() -> void:
	context = null


func _update_themes() -> void:
	_print.debug("_update_themes()")
	var base_control : Control = context.base_control
	
	if category_control_height == UNASSIGNED:
		var editor_inspector_category_control := base_control.find_children("*", "EditorInspectorCategory", true, false)[0]
		category_control_height = editor_inspector_category_control.size.y

	var theme_updates := [
		{
			"group_name": "TBTEditorInspectorCategory",
			"updates": [
				{
					"property": "theme_override_styles/panel",
					"value":  base_control.get_theme_stylebox("bg", "EditorInspectorCategory"),
				},
				{
					"property": "custom_minimum_size",
					"value": Vector2i(0, category_control_height),
				}
			],
		},
		{
			"group_name": "TBTEditorInspectorCategoryLabel",
			"updates": [
				{
					"property": "theme_override_colors/font_color",
					"value":  base_control.get_theme_color("font_color", "Label"),
				},
				{
					"property": "theme_override_fonts/font",
					"value":  base_control.get_theme_font("main_button_font", "EditorFonts"),
				},
				{
					"property": "theme_override_font_sizes/font_size",
					"value":  base_control.get_theme_font_size("main_button_font_size", "EditorFonts"),
				},
			],
		},
		{
			"group_name": "TBTPreviewHeader",
			"updates": [
				{
					"property": "theme_override_colors/font_color",
					"value":  base_control.get_theme_color("font_color", "Label"),
				},
				{
					"property": "theme_override_fonts/font",
					"value":  base_control.get_theme_font("main_button_font", "EditorFonts"),
				},
				{
					"property": "theme_override_font_sizes/font_size",
					"value":  base_control.get_theme_font_size("main_button_font_size", "EditorFonts"),
				},
			],
		},
		{
			"group_name": "TBTPreviewSubHeader",
			"updates": [
				{
					"property": "theme_override_colors/font_color",
					"value":  base_control.get_theme_color("font_color", "Label"),
				},
				{
					"property": "theme_override_fonts/font",
					"value":  base_control.get_theme_font("main_button_font", "EditorFonts"),
				},
				{
					"property": "theme_override_font_sizes/font_size",
					"value":  base_control.get_theme_font_size("main_button_font_size", "EditorFonts"),
				},
			],
		},
		{
			"group_name": "TBTPropertyLabel",
			"updates": [
				{
					"property": "theme_override_colors/font_color",
					"value":  base_control.get_theme_color("property_color", "Editor"),
				},
				{
					"property": "theme_override_fonts/font",
					"value":  base_control.get_theme_font("font", "Label"),
				},
				{
					"property": "theme_override_font_sizes/font_size",
					"value":  base_control.get_theme_font_size("main_size", "EditorFonts"),
				},
			],
		},

#		{
#			"group_name": "TBTSectionButton",
#			"updates": [
#				{
#					"property": "theme_override_colors/font_color",
#					"value":  base_control.get_theme_color("font_color", "EditorInspectorSection"),
#				},
#				{
#					"property": "theme_override_fonts/font",
#					"value":  base_control.get_theme_font("main_button_font", "EditorFonts"),
#				},
#				{
#					"property": "theme_override_font_sizes/font_size",
#					"value":  base_control.get_theme_font_size("main_button_font_size", "EditorFonts"),
#				},
#				{
#					"property": "theme_override_styles/normal",
#					"value": base_control.get_theme_stylebox("custom_button", "Tree"),
#				},
#				{
#					"property": "theme_override_styles/pressed",
#					"value": base_control.get_theme_stylebox("custom_button_pressed", "Tree"),
#				},
#				{
#					"property": "theme_override_styles/hover",
#					"value": base_control.get_theme_stylebox("custom_button_hover", "Tree"),
#				},
##				{
##					"property": ,
##					"value": base_control.,
##				},
#			],
#		},


# ###########################################################################
# 							PREVIEW PANEL
# ###########################################################################
		{
			"group_name": "TBTPreviewPanelBackground",
			"updates": [
				{
					"property": "theme_override_styles/panel",
					"value":  base_control.get_theme_stylebox("BottomPanel", "EditorStyles"),
				},
			],
		},
		{
			"group_name": "TBTPreviewPanelForeground",
			"updates": [
				{
					"property": "theme_override_styles/panel",
					"value": base_control.get_theme_stylebox("LaunchPadNormal", "EditorStyles"),
				},
			],
		},
		{
			"group_name": "TBTPreviewContainer",
			"updates": [
				{
					"property": "theme_override_styles/panel",
					"value":  base_control.get_theme_stylebox("LaunchPadNormal", "EditorStyles"),
				},
			],
		},
		{
			"group_name": "TBTPreviewBox",
			"updates": [
				{
					"property": "theme_override_styles/panel",
					"value":  base_control.get_theme_stylebox("child_bg", "EditorProperty"),
				},
			],
		},
		{
			"group_name": "TBTPlaceholderLabel",
			"updates": [
				{
					"property": "theme_override_colors/default_color",
					"value":  base_control.get_theme_color("property_color", "Editor"),
				},
				{
					"property": "theme_override_fonts/normal_font",
					"value":  base_control.get_theme_font("font", "Label"),
				},
				{
					"property": "theme_override_font_sizes/normal_font_size",
					"value":  base_control.get_theme_font_size("main_size", "EditorFonts"),
				},
			],
		},


# ###########################################################################
# 							TEMPLATE INSPECTOR
# ###########################################################################
		
		
		{
			"group_name": "TBTTemplateInspectorBackground",
			"updates": [
				{
					"property": "theme_override_styles/panel",
					"value":  base_control.get_theme_stylebox("sub_inspector_property_bg0", "Editor"),
				},
			],
		},
		{
			"group_name": "TBTTemplateInspectorForeground",
			"updates": [
				{
					"property": "theme_override_styles/panel",
					"value": base_control.get_theme_stylebox("sub_inspector_bg0", "Editor"),
				},
			],
		},
		{
			"group_name": "TBTDescriptionBox",
			"updates": [
				{
					"property": "theme_override_styles/panel",
					"value": base_control.get_theme_stylebox("bg_group_note", "EditorProperty"),
				},
			],
		},
		{
			"group_name": "TBTSubPropertyPanel",
			"updates": [
				{
					"property": "theme_override_styles/panel",
					"value": base_control.get_theme_stylebox("Information3dViewport", "EditorStyles"),
				},
			],
		},
		{
			"group_name": "TBTTag",
			"updates": [
				{
					"property": "theme_override_styles/panel",
					"value": base_control.get_theme_stylebox("selected", "ItemList"),
				},
			],
		},
		
		


# ###########################################################################
# 							DIALOG
# ###########################################################################
		{
			"group_name": "TBTDialogWindow",
			"updates": [
				{
					"property": "theme_override_styles/embedded_border",
					"value": base_control.get_theme_stylebox("embedded_border", "Window"),
				},
			],
		},
		{
			"group_name": "TBTDialogPanel",
			"updates": [
				{
					"property": "theme_override_styles/panel",
					"value":  base_control.get_theme_stylebox("PanelForeground", "EditorStyles"),
				},
			],
		},
		{
			"group_name": "TBTSeparator",
			"updates": [
				{
					"property": "theme_override_styles/separator",
					"value":  base_control.get_theme_stylebox("separator", "HSeparator"),
				},
			],
		},
		{
			"group_name": "TBTLineEdit",
			"updates": [
				{
					"property": "theme_override_styles/normal",
					"value": base_control.get_theme_stylebox("normal", "LineEdit"),
				},
				{
					"property": "theme_override_styles/focus",
					"value": base_control.get_theme_stylebox("focus", "LineEdit"),
				},
				{
					"property": "theme_override_styles/read_only",
					"value": base_control.get_theme_stylebox("read_only", "LineEdit"),
				},
			],
		},
		{
			"group_name": "TBTTextEdit",
			"updates": [
				{
					"property": "theme_override_styles/focus",
					"value": base_control.get_theme_stylebox("focus", "TextEdit"),
				},
				{
					"property": "theme_override_styles/normal",
					"value": base_control.get_theme_stylebox("normal", "TextEdit"),
				},
				{
					"property": "theme_override_styles/read_only",
					"value": base_control.get_theme_stylebox("read_only", "TextEdit"),
				},
			],
		},
		{
			"group_name": "TBTEditFont",
			"updates": [
				{
					"property": "theme_override_colors/font_color",
					"value": base_control.get_theme_color("font_color", "LineEdit"),
				},
				{
					"property": "theme_override_colors/font_selected_color",
					"value": base_control.get_theme_color("font_selected_color", "LineEdit"),
				},
				{
					"property": "theme_override_colors/font_placeholder_color",
					"value": base_control.get_theme_color("font_placeholder_color", "LineEdit"),
				},
				{
					"property": "theme_override_colors/selection_color",
					"value": base_control.get_theme_color("selection_color", "LineEdit"),
				},
				{
					"property": "theme_override_colors/caret_color",
					"value": base_control.get_theme_color("caret_color", "LineEdit"),
				},
				{
					"property": "theme_override_colors/clear_button_color",
					"value": base_control.get_theme_color("clear_button_color", "LineEdit"),
				},
				{
					"property": "theme_override_colors/clear_button_color_pressed",
					"value": base_control.get_theme_color("clear_button_color_pressed", "LineEdit"),
				},
				{
					"property": "theme_override_font_sizes/font_size",
					"value":  base_control.get_theme_font_size("main_size", "EditorFonts"),
				},
			],
		},



# ###########################################################################
# 							CONTROLS
# ###########################################################################
		{
			"group_name": "TBTOptionButton",
			"updates": [
				{
					"property": "theme_override_styles/pressed",
					"value":  base_control.get_theme_stylebox("pressed", "OptionButton"),
				},
				{
					"property": "theme_override_styles/normal",
					"value":  base_control.get_theme_stylebox("normal", "OptionButton"),
				},
				{
					"property": "theme_override_styles/hover",
					"value":  base_control.get_theme_stylebox("hover", "OptionButton"),
				},
				{
					"property": "theme_override_styles/focus",
					"value":  base_control.get_theme_stylebox("focus", "OptionButton"),
				},
				{
					"property": "theme_override_styles/disabled",
					"value":  base_control.get_theme_stylebox("disabled", "OptionButton"),
				},
			],
		},
		{
			"group_name": "TBTHSlider",
			"updates": [
				{
					"property": "theme_override_styles/slider",
					"value":  base_control.get_theme_stylebox("slider", "HSlider"),
				},
				{
					"property": "theme_override_styles/grabber_area",
					"value":  base_control.get_theme_stylebox("grabber_area", "HSlider"),
				},
				{
					"property": "theme_override_styles/grabber_area_highlight",
					"value":  base_control.get_theme_stylebox("grabber_area_highlight", "HSlider"),
				},
			],
		},
		{
			"group_name": "TBTTextButton",
			"updates": [
				{
					"property": "theme_override_styles/disabled",
					"value":  base_control.get_theme_stylebox("disabled", "InspectorActionButton"),
				},
				{
					"property": "theme_override_styles/hover",
					"value":  base_control.get_theme_stylebox("hover", "InspectorActionButton"),
				},
				{
					"property": "theme_override_styles/normal",
					"value":  base_control.get_theme_stylebox("normal", "InspectorActionButton"),
				},
				{
					"property": "theme_override_styles/pressed",
					"value":  base_control.get_theme_stylebox("pressed", "InspectorActionButton"),
				},
				{
					"property": "theme_override_font_sizes/font_size",
					"value":  base_control.get_theme_font_size("main_size", "EditorFonts"),
				},
			],
		},
		{
			"group_name": "TBTMenuButton",
			"updates": [
				{
					"property": "theme_override_styles/normal",
					"value": base_control.get_theme_stylebox("normal", "MenuButton"),
				},
				{
					"property": "theme_override_styles/pressed",
					"value": base_control.get_theme_stylebox("pressed", "MenuButton"),
				},
				{
					"property": "theme_override_styles/hover",
					"value": base_control.get_theme_stylebox("hover", "MenuButton"),
				},
				{
					"property": "theme_override_styles/disabled",
					"value": base_control.get_theme_stylebox("disabled", "MenuButton"),
				},
				{
					"property": "theme_override_styles/focus",
					"value": base_control.get_theme_stylebox("focus", "MenuButton"),
				},
			],
		},
		{
			"group_name": "TBTBackgroundPanel",
			"updates": [
				{
					"property": "theme_override_styles/panel",
					"value":  base_control.get_theme_stylebox("panel", "Tree"),
				},
			],
		},
				{
			"group_name": "TBTSectionButton",
			"updates": [
				{
					"property": "theme_override_styles/disabled",
					"value":  base_control.get_theme_stylebox("disabled", "InspectorActionButton"),
				},
				{
					"property": "theme_override_styles/hover",
					"value":  base_control.get_theme_stylebox("hover", "InspectorActionButton"),
				},
				{
					"property": "theme_override_styles/normal",
					"value":  base_control.get_theme_stylebox("normal", "InspectorActionButton"),
				},
				{
					"property": "theme_override_styles/pressed",
					"value":  base_control.get_theme_stylebox("normal", "InspectorActionButton"),
				},
				{
					"property": "theme_override_colors/font_color",
					"value":  base_control.get_theme_color("font_color", "EditorInspectorSection"),
				},
				{
					"property": "theme_override_colors/font_pressed_color",
					"value":  base_control.get_theme_color("font_color", "EditorInspectorSection"),
				},
				{
					"property": "theme_override_colors/font_hover_color",
					"value":  base_control.get_theme_color("font_color", "EditorInspectorSection"),
				},
				{
					"property": "theme_override_fonts/font",
					"value":  base_control.get_theme_font("main_button_font", "EditorFonts"),
				},
				{
					"property": "theme_override_font_sizes/font_size",
					"value":  base_control.get_theme_font_size("main_button_font_size", "EditorFonts"),
				},
			],
		},
	]

	
	for entry in theme_updates:
		for update in entry.updates:
			get_tree().call_group(entry.group_name, "set", update.property, update.value)


