@tool
extends Node


const THEME_TYPE := 0
const THEME_CATEGORY := 1
const THEME_DATA_TYPE := 2

const UNASSIGNED := -1

const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")



const ThemeMethods := {
	Theme.DATA_TYPE_COLOR: "get_theme_color",
}

const PanelOverrides := {
	"TBTPreviewPanelBackground": ["BottomPanel", "EditorStyles"],
	"TBTPreviewPanelForeground": ["bg", "GraphEdit"],
}


const FontOverrides := {
	"TBTPropertyLabel": {
		"theme_override_colors/font_color": 
			["property_color", "Editor", Theme.DATA_TYPE_COLOR],
	},
}





var context : TBTPlugin.Context
var category_control_height := UNASSIGNED


# TODO: add request_apply_style for styling runtime generated controls

var tbt : TBTPlugin


func _tbt_ready() -> void:
	_update_dialogs()


func _tiles_inspector_added() -> void:
	await get_tree().process_frame
	_update_themes()


func _update_dialogs() -> void:
	for dialog in tbt.dialog_windows:
		dialog.theme = tbt.base_control.theme


func _update_panels() -> void:
	for group in PanelOverrides.keys():
		var panel := tbt.base_control.get_theme_stylebox(
			PanelOverrides[group][THEME_TYPE], 
			PanelOverrides[group][THEME_CATEGORY]
		)
		get_tree().set_group(group, "theme_override_styles/panel", panel)
	



func _update_fonts() -> void:
	for group in FontOverrides.keys():
		for property in FontOverrides[group].keys():
			var override : Array = FontOverrides[group][property]
			var method : String = ThemeMethods[override[THEME_DATA_TYPE]]
			var value = tbt.base_control.call(
				method, 
				override[THEME_TYPE], 
				override[THEME_CATEGORY]
			)
			get_tree().set_group(group, property, value)
		
#		for data_type in FontOverrides[group].keys():
#			var method : String = ThemeMethods[data_type]
#			var args : Array = FontOverrides[group][data_type]
#			var data = tbt.base_control.callv(method, args)
	
	
#const FontOverrides := {
#	"TBTPropertyLabel": {
#		"theme_override_colors/font_color": 
#			["property_color", "Editor", Theme.DATA_TYPE_COLOR],
#	}
#}





func _update_themes() -> void:
	tbt.output.debug("_update_themes()")
	_update_panels()
	_update_fonts()
	return
	
	
	var base_control : Control = tbt.context.base_control
	
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



# ###########################################################################
# 							PREVIEW PANEL
# ###########################################################################
		
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


