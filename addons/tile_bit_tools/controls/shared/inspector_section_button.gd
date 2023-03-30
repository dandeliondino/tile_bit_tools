@tool
extends Button


const LABEL_MARGIN_ADJUST := -6

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
@onready var arrow_margin_container: MarginContainer = $ArrowMarginContainer
@onready var label_margin_container: MarginContainer = $LabelMarginContainer



func _ready() -> void:
	_update_label_text()


func _enter_tree() -> void:
	_update_height()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		if !is_instance_valid(tbt):
			return
		_update_colors()


func _tbt_ready() -> void:
	expand_container = get_node_or_null(expand_container_path)
	if expand_container == null:
		tbt.output.error("Expand container null")
		return
	
	icon_expanded = tbt.icons.get_icon(tbt.icons.ARROW_EXPANDED)
	icon_collapsed = tbt.icons.get_icon(tbt.icons.ARROW_COLLAPSED)
	_toggle_expanded(false)
	
	_toggle_hover(false)
	
	var left_margin = round(2 * tbt.interface.get_editor_scale())
	arrow_margin_container.set("theme_override_constants/margin_left", left_margin)
	
	var label_margin = left_margin + icon_expanded.get_size().x + LABEL_MARGIN_ADJUST
	label_margin_container.set("theme_override_constants/margin_left", label_margin)

	_update_colors()
	_update_height()



# inspector section colors are calculated in the core cpp files
# unlike height, it is not possible to get directly from inspector section nodes
# so this re-creates the calculations
func _update_colors() -> void:
	var base_control := tbt.get_editor_node(tbt.EditorTreeNode.BASE_CONTROL)
	normal_color = base_control.get_theme_color("prop_subsection", "Editor")
	normal_color.a = normal_color.a * 0.4
	hover_color = normal_color.lightened(0.2)
	

# inspector section height is calculated in the core cpp files
# it's easier to get from an already-created node than to re-create the calculations
# this is done in a few different times and places
# (from this script and from theme_updater)
# it's a bit messy, but low cost and it's otherwise difficult to ensure 
# it is being updated on time and with the correct number
func _update_height() -> void:
	if tbt:
		custom_minimum_size.y = tbt.theme_updater.section_button_height
	


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


func _on_toggled(p_button_pressed: bool) -> void:
	_toggle_expanded(p_button_pressed)
