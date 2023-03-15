@tool
extends Control


const UNASSIGNED := -1

const CATEGORY_EDITOR_CLASS := "EditorInspectorCategory"
const SECTION_EDITOR_CLASS := "EditorInspectorSection"
const CATEGORY_PANEL_GROUP := "TBTCategoryPanel"
const SECTION_BUTTON_GROUP := "TBTSectionButton"
const DEFAULT_MINIMUM_HEIGHT := 16



const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")




enum Overrides {
	FONT, FONT_SIZE, FONT_COLOR, # Label
	NORMAL_FONT, NORMAL_FONT_SIZE, DEFAULT_COLOR, # RichTextLabel
	PANEL, WINDOW_PANEL,  # Panel
	BUTTON_NORMAL, BUTTON_HOVER, BUTTON_PRESSED, BUTTON_DISABLED, BUTTON_FOCUS, # Button
}

var override_properties := {
	Overrides.FONT: "theme_override_fonts/font",
	Overrides.FONT_SIZE: "theme_override_font_sizes/font_size",
	Overrides.FONT_COLOR: "theme_override_colors/font_color",
	Overrides.NORMAL_FONT: "theme_override_fonts/normal_font",
	Overrides.NORMAL_FONT_SIZE: "theme_override_font_sizes/normal_font_size",
	Overrides.DEFAULT_COLOR: "theme_override_colors/default_color", 
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
	Overrides.NORMAL_FONT: "get_theme_font",
	Overrides.NORMAL_FONT_SIZE: "get_theme_font_size",
	Overrides.DEFAULT_COLOR: "get_theme_color", 
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
		Overrides.FONT: ["main", "EditorFonts"],
		Overrides.FONT_SIZE: ["main_size", "EditorFonts"],
		Overrides.FONT_COLOR: ["property_color", "Editor"],
	},
	"TBTSubPropertyLabel": {
		Overrides.FONT: ["main", "EditorFonts"],
		Overrides.FONT_SIZE: ["main_size", "EditorFonts"],
		Overrides.FONT_COLOR: ["sub_inspector_property_color", "Editor"],
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
	"TBTPreviewHBoxPanel": {
		Overrides.PANEL: ["panel", "Tree"],
	},
	"TBTPlaceholderLabel": {
		Overrides.NORMAL_FONT: ["font", "Label"],
		Overrides.NORMAL_FONT_SIZE: ["main_size", "EditorFonts"],
		Overrides.DEFAULT_COLOR: ["property_color", "Editor"],
	},

	
	# SAVE/EDIT DIALOGS
	"TBTDialogWindow": {
		Overrides.WINDOW_PANEL: ["panel", "ProjectSettingsEditor"],
	},
	"TBTDialogPanelBackground": {
		Overrides.PANEL: ["Background", "EditorStyles"],
	},
	"TBTDialogPanelForeground": {
		Overrides.PANEL: ["PanelForeground", "EditorStyles"],
	},
	"TBTDialogPanelSection": {
		Overrides.PANEL: ["panel", "Tree"],
	},
	
	
	# BUTTONS
	"TBTTextButton": {
		Overrides.FONT_COLOR: ["font_color", "Editor"],
		Overrides.FONT: ["main_button_font", "EditorFonts"],
		Overrides.FONT_SIZE: ["main_button_font_size", "EditorFonts"],
#		Overrides.FONT: ["bold", "EditorFonts"],
#		Overrides.FONT_SIZE: ["bold_size", "EditorFonts"],
		
		Overrides.BUTTON_NORMAL: ["normal", "OptionButton"],
		Overrides.BUTTON_HOVER: ["hover", "OptionButton"],
		Overrides.BUTTON_PRESSED: ["pressed", "OptionButton"],
		Overrides.BUTTON_DISABLED: ["disabled", "OptionButton"],
		Overrides.BUTTON_FOCUS: ["focus", "OptionButton"],
	}
}


var category_panel_height := UNASSIGNED
var section_button_height := UNASSIGNED

var height_setup_complete := false

# TODO: add request_apply_style for styling runtime generated controls

var tbt : TBTPlugin


func _tbt_ready() -> void:
	tbt.theme_update_requested.connect(_on_theme_update_requested)
	_setup_themes()

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		if !is_instance_valid(tbt):
			return
		_setup_themes()



func _tiles_inspector_added() -> void:
	await get_tree().process_frame
	if !height_setup_complete:
		# if done under _setup_themes(), will not get get heights 
		# if plugin activated on editor launch
		_setup_custom_heights()
	
#	_setup_dynamic_containers()
	_update_themes()


# TODO: also call this from notification theme changed
func _setup_themes() -> void:
	height_setup_complete = false
	_update_themes()


func _update_themes() -> void:
	tbt.output.debug("_update_themes()")
	_update_groups()
	_update_custom_heights()



func _update_groups() -> void:
	for group in overrides_dict.keys():
		for override in overrides_dict[group].keys():
			var method : String = override_methods[override]
			var args : Array = overrides_dict[group][override]
			var property : String = override_properties[override]
			var value = tbt.base_control.callv(method, args)
			get_tree().set_group(group, property, value)
			

func _update_node(node : Node) -> void:
	for group in overrides_dict.keys():
		if node.is_in_group(group):
			for override in overrides_dict[group].keys():
				var method : String = override_methods[override]
				var args : Array = overrides_dict[group][override]
				var property : String = override_properties[override]
				var value = tbt.base_control.callv(method, args)
				node.set(property, value)


func _setup_custom_heights() -> void:
	category_panel_height = max(_get_height_by_class(CATEGORY_EDITOR_CLASS), DEFAULT_MINIMUM_HEIGHT)
	section_button_height = max(_get_height_by_class(SECTION_EDITOR_CLASS), DEFAULT_MINIMUM_HEIGHT)
#	prints("category_panel_height", category_panel_height)
#	prints("section_button_height", section_button_height)
	height_setup_complete = true


func _update_custom_heights() -> void:
	get_tree().set_group(CATEGORY_PANEL_GROUP, "custom_minimum_size", Vector2i(0, category_panel_height))
	get_tree().set_group(SECTION_BUTTON_GROUP, "custom_minimum_size", Vector2i(0, section_button_height))


#func _setup_dynamic_containers() -> void:
#	for node in get_tree().get_nodes_in_group(tbt.Globals.GROUP_DYNAMIC_CONTAINER):
#		if !node.child_entered_tree.is_connected(_on_dynamic_container_child_added):
#			node.child_entered_tree.connect(_on_dynamic_container_child_added)


func _on_theme_update_requested(node : Node) -> void:
	await get_tree().process_frame
	_update_node(node)
	for child in node.find_children("*", "", true, false):
		_update_node(child)

# finds first control of class that has a height > 0
# returns height
func _get_height_by_class(p_class_name : String) -> int:
	var controls := tbt.base_control.find_children("*", p_class_name, true, false)
	for control in controls:
		var height : int = control.size.y
		if height > 0:
			return height
	return 0

	
	


	

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

