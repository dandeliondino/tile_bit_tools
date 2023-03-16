@tool
extends Button

# TODO: delete this script
const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")

@export_node_path("Control") var expand_control_path: NodePath

var arrow_collapsed : Texture2D
var arrow_expanded : Texture2D

var expand_control : Control

var tbt : TBTPlugin


func _tbt_ready() -> void:
	var base_control := tbt.base_control
	arrow_collapsed = base_control.get_theme_icon("GuiTreeArrowRight", "EditorIcons")
	arrow_expanded = base_control.get_theme_icon("GuiTreeArrowDown", "EditorIcons")
	
	expand_control = get_node(expand_control_path)
	toggle_mode = true
	toggled.connect(_on_toggled)
	_update_toggle()


func _update_toggle() -> void:
	if !is_instance_valid(expand_control):
		return
	
	if button_pressed:
		_expand()
	else:
		_collapse()


func _expand() -> void:
#	print("_expand()")
	icon = arrow_expanded
	expand_control.show()


func _collapse() -> void:
#	print("_collapse()")
	icon = arrow_collapsed
	expand_control.hide()


func _on_toggled(_button_pressed: bool) -> void:
#	print("toggled")
	_update_toggle()

