@tool
extends Control


const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
const Context := preload("res://addons/tile_bit_tools/core/context.gd")
const InspectorManager := preload("res://addons/tile_bit_tools/controls/shared_nodes/inspector_manager.gd")

var _print := preload("res://addons/tile_bit_tools/core/print.gd").new()

@onready var inspector_manager : InspectorManager = get_tree().get_first_node_in_group(Globals.GROUP_INSPECTOR_MANAGER)







func _on_save_button_pressed() -> void:
	inspector_manager.save_template_requested.emit(inspector_manager.get_current_context())
