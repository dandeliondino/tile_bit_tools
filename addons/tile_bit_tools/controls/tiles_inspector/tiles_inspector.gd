@tool
extends Control

const TBTPlugin := preload("res://addons/tile_bit_tools/controls/shared_nodes/tbt_plugin_control.gd")

var tbt : TBTPlugin

var ready_complete := false

func _ready() -> void:
	ready_complete = true


func _on_save_button_pressed() -> void:
	tbt.inspector_manager.save_template_requested.emit(tbt.context)
