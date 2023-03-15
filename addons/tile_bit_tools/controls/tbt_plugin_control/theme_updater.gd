@tool
extends Node


const UNASSIGNED := -1

const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")




enum Overrides {
	FONT, FONT_SIZE, FONT_COLOR, 
	PANEL, WINDOW_PANEL, 
	BUTTON_NORMAL, BUTTON_HOVER, BUTTON_PRESSED, BUTTON_DISABLED, BUTTON_FOCUS,
}

var override_properties := {
	Overrides.FONT: "theme_override_fonts/font",
	Overrides.FONT_SIZE: "theme_override_font_sizes/font_size",
	Overrides.FONT_COLOR: "theme_override_colors/font_color",
	Overrides.PANEL: "theme_override_styles/panel",
	Overrides.WINDOW_PANEL: "theme_override_styles/embedded_border",
	Overrides.BUTTON_NORMAL: "theme_override_styles/normal",
	Overrides.BUTTON_HOVER: "theme_override_styles/hover",
	Overrides.BUTTON_PRESSED: "theme_override_styles/pressed",
	Overrides.BUTTON_DISABLED: "theme_override_styles/disabled",
	Overrides.BUTTON_FOCUS: "theme_override_styles/focus",
}

var override_methods := {
	Overrides.FONT: "get_theme_font",
	Overrides.FONT_SIZE: "get_theme_font_size",
	Overrides.FONT_COLOR: "get_theme_color",
	Overrides.PANEL: "get_theme_stylebox",
	Overrides.WINDOW_PANEL: "get_theme_stylebox",
	Overrides.BUTTON_NORMAL: "get_theme_stylebox",
	Overrides.BUTTON_HOVER: "get_theme_stylebox",
	Overrides.BUTTON_PRESSED: "get_theme_stylebox",
	Overrides.BUTTON_DISABLED: "get_theme_stylebox",
	Overrides.BUTTON_FOCUS: "get_theme_stylebox",
}

var overrides_dict := {
	# ----------------------------------------------------
	#			FONTS
	# ----------------------------------------------------
	"TBTCategoryLabel": {
		Overrides.FONT: ["bold", "EditorFonts"],
		Overrides.FONT_SIZE: ["bold_size", "EditorFonts"],
		Overrides.FONT_COLOR: ["font_color", "Editor"],
	},
	"TBTSectionLabel": {
		Overrides.FONT: ["bold", "EditorFonts"],
		Overrides.FONT_SIZE: ["bold_size", "EditorFonts"],
		Overrides.FONT_COLOR: ["font_color", "Editor"],
	},
	"TBTPropertyLabel": {
		Overrides.FONT_COLOR: ["property_color", "Editor"],
	},
	
	# ----------------------------------------------------
	#			PANELS
	# ----------------------------------------------------
	# TILES INSPECTOR
	"TBTCategoryPanel": {
		Overrides.PANEL: ["bg", "EditorInspectorCategory"],
	},
	
	# TILES PREVIEW
	"TBTPreviewPanelBackground": {
		Overrides.PANEL: ["BottomPanel", "EditorStyles"],
	},
	"TBTPreviewPanelForeground": {
		Overrides.PANEL: ["bg", "GraphEdit"],
	},
	
	# SAVE/EDIT DIALOGS
	"TBTDialogWindow": {
		Overrides.WINDOW_PANEL: ["panel", "EditorSettingsDialog"],
	},
	
	
	# BUTTONS
	"TBTTextButton": {
		Overrides.FONT_COLOR: ["font_color", "Editor"],
		Overrides.FONT: ["bold", "EditorFonts"],
		Overrides.FONT_SIZE: ["bold_size", "EditorFonts"],
		
		Overrides.BUTTON_NORMAL: ["normal", "OptionButton"],
		Overrides.BUTTON_HOVER: ["hover", "OptionButton"],
		Overrides.BUTTON_PRESSED: ["pressed", "OptionButton"],
		Overrides.BUTTON_DISABLED: ["disabled", "OptionButton"],
		Overrides.BUTTON_FOCUS: ["focus", "OptionButton"],
	}
}


var category_height := UNASSIGNED
var section_height := UNASSIGNED

# TODO: add request_apply_style for styling runtime generated controls

var tbt : TBTPlugin


func _tbt_ready() -> void:
	pass


func _tiles_inspector_added() -> void:
	await get_tree().process_frame
	_update_themes()





func _update_dialogs() -> void:
	for dialog in tbt.dialog_windows:
		dialog.theme = tbt.base_control.theme






func _update_overrides() -> void:
	for group in overrides_dict.keys():
		for override in overrides_dict[group].keys():
			var method : String = override_methods[override]
			var args : Array = overrides_dict[group][override]
			var property : String = override_properties[override]
			var value = tbt.base_control.callv(method, args)
			get_tree().set_group(group, property, value)
			





func _update_themes() -> void:
	tbt.output.debug("_update_themes()")
	_update_overrides()
	return
	
	
	var base_control : Control = tbt.context.base_control
#
#	if category_control_height == UNASSIGNED:
#		var editor_inspector_category_control := base_control.find_children("*", "EditorInspectorCategory", true, false)[0]
#		category_control_height = editor_inspector_category_control.size.y

#	var theme_updates := [
#		{
#			"group_name": "TBTEditorInspectorCategory",
#			"updates": [
#				{
#					"property": "theme_override_styles/panel",
#					"value":  base_control.get_theme_stylebox("bg", "EditorInspectorCategory"),
#				},
#				{
#					"property": "custom_minimum_size",
#					"value": Vector2i(0, category_control_height),
#				}
#			],
#		},
#		{
#			"group_name": "TBTEditorInspectorCategoryLabel",
#			"updates": [
#				{
#					"property": "theme_override_colors/font_color",
#					"value":  base_control.get_theme_color("font_color", "Label"),
#				},
#				{
#					"property": "theme_override_fonts/font",
#					"value":  base_control.get_theme_font("main_button_font", "EditorFonts"),
#				},
#				{
#					"property": "theme_override_font_sizes/font_size",
#					"value":  base_control.get_theme_font_size("main_button_font_size", "EditorFonts"),
#				},
#			],
#		},
#		{
#			"group_name": "TBTPreviewHeader",
#			"updates": [
#				{
#					"property": "theme_override_colors/font_color",
#					"value":  base_control.get_theme_color("font_color", "Label"),
#				},
#				{
#					"property": "theme_override_fonts/font",
#					"value":  base_control.get_theme_font("main_button_font", "EditorFonts"),
#				},
#				{
#					"property": "theme_override_font_sizes/font_size",
#					"value":  base_control.get_theme_font_size("main_button_font_size", "EditorFonts"),
#				},
#			],
#		},
#		{
#			"group_name": "TBTPreviewSubHeader",
#			"updates": [
#				{
#					"property": "theme_override_colors/font_color",
#					"value":  base_control.get_theme_color("font_color", "Label"),
#				},
#				{
#					"property": "theme_override_fonts/font",
#					"value":  base_control.get_theme_font("main_button_font", "EditorFonts"),
#				},
#				{
#					"property": "theme_override_font_sizes/font_size",
#					"value":  base_control.get_theme_font_size("main_button_font_size", "EditorFonts"),
#				},
#			],
#		},
#
#
#
## ###########################################################################
## 							PREVIEW PANEL
## ###########################################################################
#
#		{
#			"group_name": "TBTPreviewContainer",
#			"updates": [
#				{
#					"property": "theme_override_styles/panel",
#					"value":  base_control.get_theme_stylebox("LaunchPadNormal", "EditorStyles"),
#				},
#			],
#		},
#		{
#			"group_name": "TBTPreviewBox",
#			"updates": [
#				{
#					"property": "theme_override_styles/panel",
#					"value":  base_control.get_theme_stylebox("child_bg", "EditorProperty"),
#				},
#			],
#		},
#		{
#			"group_name": "TBTPlaceholderLabel",
#			"updates": [
#				{
#					"property": "theme_override_colors/default_color",
#					"value":  base_control.get_theme_color("property_color", "Editor"),
#				},
#				{
#					"property": "theme_override_fonts/normal_font",
#					"value":  base_control.get_theme_font("font", "Label"),
#				},
#				{
#					"property": "theme_override_font_sizes/normal_font_size",
#					"value":  base_control.get_theme_font_size("main_size", "EditorFonts"),
#				},
#			],
#		},
#
#
## ###########################################################################
## 							TEMPLATE INSPECTOR
## ###########################################################################
#
#
#		{
#			"group_name": "TBTTemplateInspectorBackground",
#			"updates": [
#				{
#					"property": "theme_override_styles/panel",
#					"value":  base_control.get_theme_stylebox("sub_inspector_property_bg0", "Editor"),
#				},
#			],
#		},
#		{
#			"group_name": "TBTTemplateInspectorForeground",
#			"updates": [
#				{
#					"property": "theme_override_styles/panel",
#					"value": base_control.get_theme_stylebox("sub_inspector_bg0", "Editor"),
#				},
#			],
#		},
#		{
#			"group_name": "TBTDescriptionBox",
#			"updates": [
#				{
#					"property": "theme_override_styles/panel",
#					"value": base_control.get_theme_stylebox("bg_group_note", "EditorProperty"),
#				},
#			],
#		},
#		{
#			"group_name": "TBTSubPropertyPanel",
#			"updates": [
#				{
#					"property": "theme_override_styles/panel",
#					"value": base_control.get_theme_stylebox("Information3dViewport", "EditorStyles"),
#				},
#			],
#		},
#		{
#			"group_name": "TBTTag",
#			"updates": [
#				{
#					"property": "theme_override_styles/panel",
#					"value": base_control.get_theme_stylebox("selected", "ItemList"),
#				},
#			],
#		},
#
#
#
#
## ###########################################################################
## 							DIALOG
## ###########################################################################
#		{
#			"group_name": "TBTDialogWindow",
#			"updates": [
#				{
#					"property": "theme_override_styles/embedded_border",
#					"value": base_control.get_theme_stylebox("embedded_border", "Window"),
#				},
#			],
#		},
#		{
#			"group_name": "TBTDialogPanel",
#			"updates": [
#				{
#					"property": "theme_override_styles/panel",
#					"value":  base_control.get_theme_stylebox("PanelForeground", "EditorStyles"),
#				},
#			],
#		},
#
#
#
## ###########################################################################
## 							CONTROLS
## ###########################################################################
#
#
#
#
#
#
#		{
#			"group_name": "TBTBackgroundPanel",
#			"updates": [
#				{
#					"property": "theme_override_styles/panel",
#					"value":  base_control.get_theme_stylebox("panel", "Tree"),
#				},
#			],
#		},
#				{
#			"group_name": "TBTSectionButton",
#			"updates": [
#				{
#					"property": "theme_override_styles/disabled",
#					"value":  base_control.get_theme_stylebox("disabled", "InspectorActionButton"),
#				},
#				{
#					"property": "theme_override_styles/hover",
#					"value":  base_control.get_theme_stylebox("hover", "InspectorActionButton"),
#				},
#				{
#					"property": "theme_override_styles/normal",
#					"value":  base_control.get_theme_stylebox("normal", "InspectorActionButton"),
#				},
#				{
#					"property": "theme_override_styles/pressed",
#					"value":  base_control.get_theme_stylebox("normal", "InspectorActionButton"),
#				},
#				{
#					"property": "theme_override_colors/font_color",
#					"value":  base_control.get_theme_color("font_color", "EditorInspectorSection"),
#				},
#				{
#					"property": "theme_override_colors/font_pressed_color",
#					"value":  base_control.get_theme_color("font_color", "EditorInspectorSection"),
#				},
#				{
#					"property": "theme_override_colors/font_hover_color",
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
#			],
#		},
#	]

#
#	for entry in theme_updates:
#		for update in entry.updates:
#			get_tree().call_group(entry.group_name, "set", update.property, update.value)
#

