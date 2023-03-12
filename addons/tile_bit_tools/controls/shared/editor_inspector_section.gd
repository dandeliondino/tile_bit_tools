@tool
extends Button

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
const Context := preload("res://addons/tile_bit_tools/core/context.gd")

@onready var context : Context = get_tree().get_first_node_in_group(Globals.GROUP_CONTEXT)
@onready var base_control := context.base_control

var EditorInspectorSectionStylebox := preload("res://addons/tile_bit_tools/controls/shared/editor_inspector_section.tres")

var stylebox_normal := EditorInspectorSectionStylebox.duplicate()
var stylebox_hover := EditorInspectorSectionStylebox.duplicate()

#var font := base_control.get_theme_font("bold", "EditorFonts")
#var font_size := base_control.get_theme_font_size("bold_size", "EditorFonts")
#var font_color := base_control.get_theme_color("font_color", "Editor")


@onready var font := base_control.get_theme_font("bold", "EditorFonts")
@onready var font_size := base_control.get_theme_font_size("bold_size", "EditorFonts")
@onready var font_color := base_control.get_theme_color("font_color", "Editor")



@onready var icon_expanded := base_control.get_theme_icon("arrow", "Tree")
@onready var icon_collapsed := base_control.get_theme_icon("arrow_collapsed", "Tree")


var expand_container : Container = get_parent().get_child(get_index() + 1)

@onready var background_rect: ColorRect = %BackgroundRect

@onready var label: Label = %Label
@onready var icon_rect: TextureRect = %IconRect
@onready var margin_container: MarginContainer = %MarginContainer

@onready var bg_color : Color
@onready var hover_color : Color
@onready var press_color : Color


func _ready() -> void:
	print("ready()")
	var height := _get_height()
	custom_minimum_size.y = height
#	background_rect.custom_minimum_size.y = height
	prints("height", _get_height())
	
	label.set("theme_override_fonts/font", font)
	label.set("theme_override_font_sizes/font_size", font_size)
	label.set("theme_override_colors/font_color", font_color)
	
	bg_color = base_control.get_theme_color("prop_subsection", "Editor")
	bg_color.a = bg_color.a * 0.4
	
	hover_color = bg_color.lightened(0.2)

	stylebox_normal.bg_color = bg_color
	stylebox_hover.bg_color = bg_color.lightened(0.2)
	
#	set("theme_override_styles/normal", stylebox_normal)
#	set("theme_override_styles/pressed", stylebox_normal)
#	set("theme_override_styles/hover", stylebox_hover)
	
#	var indent := context.interface.get_editor_scale()
	var margin_start : int = round(2 * context.interface.get_editor_scale())
	prints("margin_start", margin_start)
	margin_container.set("theme_override_constants/margin_left", margin_start)
	
	_update_arrows(false)


func _get_height() -> int:
	var controls := base_control.find_children("*", "EditorInspectorSection", true, false)
	for control in controls:
		var height : int = control.size.y
		if height > 0:
			return height
	return 0



func _update_arrows(value) -> void:
	if value:
		icon_rect.texture = icon_expanded
	else:
		icon_rect.texture = icon_collapsed



func _on_mouse_entered() -> void:
	background_rect.color = hover_color
	

func _on_mouse_exited() -> void:
	background_rect.color = bg_color


func _on_toggled(button_pressed: bool) -> void:
	_update_arrows(button_pressed)


#func _lighten(color : Color) -> Color:
	
	
#Color lightened(float p_amount) const {
#		Color res = *this;
#		res.r = res.r + (1.0f - res.r) * p_amount;
#		res.g = res.g + (1.0f - res.g) * p_amount;
#		res.b = res.b + (1.0f - res.b) * p_amount;
#		return res;	







