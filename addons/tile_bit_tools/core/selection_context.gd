@tool
extends RefCounted

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
#const DataLayer := preload("res://addons/tile_bit_tools/core/data_layer.gd")
const PropertyLayer := preload("res://addons/tile_bit_tools/core/tile_data/property_layer.gd")


var data_layers := []

var tile_set : TileSet
var _tile_data_dict : Dictionary # AtlasCoords::TileData


func _init(p_tile_set : TileSet = null, p_tile_data_dict := {}) -> void:
	tile_set = p_tile_set
	_tile_data_dict = p_tile_data_dict
	if is_empty():
		return
	_create_data_layers()


func _create_data_layers() -> void:
	for property in Globals.tile_properties:
		var property_layer := PropertyLayer.new(property, _tile_data_dict)
		data_layers.append(property_layer)
		property_layer.print_tiles()


func is_empty() -> bool:
	return _tile_data_dict.is_empty()
