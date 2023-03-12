@tool
extends Button


const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")

# property name from icons.gd
@export var icon_name : String

var tbt : TBTPlugin

func _tbt_ready() -> void:
	icon = tbt.icons.get_icon_by_name(icon_name)

