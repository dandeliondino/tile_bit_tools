@tool
extends Button


const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")


@export var label_text := "Inspector Section" :
	set(value):
		label_text = value
		if is_instance_valid(label):
			_update_label_text()

@export var expand_container_path : NodePath

var tbt : TBTPlugin

var expand_container : Control

var icon_expanded
var icon_collapsed

var normal_color : Color
var hover_color : Color

@onready var background_rect: ColorRect = %BackgroundRect
@onready var arrow_rect: TextureRect = %ArrowRect
@onready var label: Label = %Label
@onready var left_margin_control: Control = %LeftMarginControl
@onready var h_box_container: HBoxContainer = %HBoxContainer


func _ready() -> void:
	_update_label_text()


func _tbt_ready() -> void:
	expand_container = get_node_or_null(expand_container_path)
	if expand_container == null:
		tbt.output.error("Expand container null")
	
	icon_expanded = tbt.icons.get_icon(tbt.icons.ARROW_EXPANDED)
	icon_collapsed = tbt.icons.get_icon(tbt.icons.ARROW_COLLAPSED)
	
	normal_color = tbt.base_control.get_theme_color("prop_subsection", "Editor")
	normal_color.a = normal_color.a * 0.4
	hover_color = normal_color.lightened(0.2)
	
	left_margin_control.custom_minimum_size.x = round(2 * tbt.interface.get_editor_scale())
	h_box_container.set("theme_override_constants/separation", 0)
	
	_toggle_hover(false)
	_toggle_expanded(false)


func _update_label_text() -> void:
	label.text = label_text


func _toggle_expanded(value : bool) -> void:
	if value:
		if is_instance_valid(expand_container):
			expand_container.show()
		arrow_rect.texture = icon_expanded
	else:
		if is_instance_valid(expand_container):
			expand_container.hide()
		arrow_rect.texture = icon_collapsed


func _toggle_hover(value : bool) -> void:
	if value:
		background_rect.color = hover_color
	else:
		background_rect.color = normal_color


func _on_mouse_entered() -> void:
	_toggle_hover(true)


func _on_mouse_exited() -> void:
	_toggle_hover(false)


func _on_toggled(button_pressed: bool) -> void:
	_toggle_expanded(button_pressed)
