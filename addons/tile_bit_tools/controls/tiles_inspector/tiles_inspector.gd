@tool
extends Control

const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")

var tbt : TBTPlugin

var ready_complete := false

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	ready_complete = true


func _on_save_button_pressed() -> void:
	tbt.save_template_requested.emit()


func _on_visibility_changed() -> void:
	prints("tiles_inspector visibility changed", is_visible_in_tree())
	
	
		
		
		
		
		
		










