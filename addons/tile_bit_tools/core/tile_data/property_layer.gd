extends "res://addons/tile_bit_tools/core/data_layer.gd"


var _tiles := {} # AtlasCoords::Variant
var property := ""
var default_value : Variant



func _init(p_property := "", p_tile_data_dict := {}) -> void:
	data_layer_type = Globals.DataLayer.PROPERTY
	
	property = p_property
	
	if p_tile_data_dict.is_empty() or p_property.is_empty():
		return
		
	default_value = TileData.new().get(property)
#	print("%s default value = %s" % [property, default_value])
	
	for coords in p_tile_data_dict:
		var tile_data : TileData = p_tile_data_dict[coords]
		var val = tile_data.get(property)
		if val != default_value:
			_changed_from_default = true
		_tiles[coords] = val


func get_tile_value(coords : Vector2i) -> Variant:
	return _tiles[coords]


func get_name() -> String:
	return property.capitalize()


func is_tile_changed_from_default(coords : Vector2i) -> bool:
	return _tiles[coords] != default_value


func print_tiles() -> void:
	print()
	if is_changed_from_default():
		prints(name, "(changed)")
	else:
		prints(name, "(default)")
	for coords in _tiles:
		prints(coords, get_tile_value(coords))









