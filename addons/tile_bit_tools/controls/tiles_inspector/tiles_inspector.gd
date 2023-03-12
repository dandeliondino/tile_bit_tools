@tool
extends Control

const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")

var tbt : TBTPlugin

var ready_complete := false

func _ready() -> void:
	ready_complete = true


func _on_save_button_pressed() -> void:
	tbt.save_template_requested.emit()



	
	
		
		
		
		
		
		










