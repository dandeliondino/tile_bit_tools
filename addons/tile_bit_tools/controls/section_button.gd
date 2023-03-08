@tool
extends Button

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
const InspectorManager := preload("res://addons/tile_bit_tools/controls/shared_nodes/inspector_manager.gd")

@export_node_path("Control") var expand_control_path: NodePath

var arrow_collapsed : Texture2D
var arrow_expanded : Texture2D

var expand_control : Control

@onready var inspector_manager : InspectorManager = get_tree().get_first_node_in_group(Globals.GROUP_INSPECTOR_MANAGER)


func _ready() -> void:
	var base_control := inspector_manager.get_current_context().base_control
	arrow_collapsed = base_control.get_theme_icon("GuiTreeArrowRight", "EditorIcons")
	arrow_expanded = base_control.get_theme_icon("GuiTreeArrowDown", "EditorIcons")
	
	expand_control = get_node(expand_control_path)
	toggle_mode = true
	toggled.connect(_on_toggled)
	_update_toggle()
#	print("button ready")


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

