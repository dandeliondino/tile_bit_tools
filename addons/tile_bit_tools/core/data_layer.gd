@tool
extends RefCounted

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")

var data_layer_type : Globals.DataLayer

var name := "" :
	get:
		return get_name()

var _changed_from_default := false



func get_name() -> String:
	# override this function
	return "DataLayer"


func is_changed_from_default() -> bool:
	return _changed_from_default
