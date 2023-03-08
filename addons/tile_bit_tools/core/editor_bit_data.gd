@tool
extends "res://addons/tile_bit_tools/core/bit_data.gd"

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
const TemplateBitData := preload("res://addons/tile_bit_tools/core/template_bit_data.gd")
const EditorBitData := preload("res://addons/tile_bit_tools/core/editor_bit_data.gd")

var _print := preload("res://addons/tile_bit_tools/core/print.gd").new()

var tile_set : TileSet



func make_copy() -> EditorBitData:
	var bit_data_copy := self.duplicate()
	bit_data_copy._tiles = _tiles.duplicate(true)
	bit_data_copy.tile_set = tile_set
	return bit_data_copy





func get_terrain_color(terrain_index : int) -> Color:
	if terrain_index == NULL_TERRAIN_INDEX:
		return Color.TRANSPARENT
	return tile_set.get_terrain_color(terrain_set, terrain_index)




## terrain_mapping: {template terrain_index : tile_set terrain_index}
func apply_template_bit_data(template_bit_data : TemplateBitData, p_terrain_set : int, terrain_mapping : Dictionary) -> Globals.Errors:
	clear_all_tile_terrains()
	
	terrain_set = p_terrain_set
	terrain_mode = template_bit_data.terrain_mode
	if tile_set.get_terrain_set_mode(terrain_set) != terrain_mode:
		return Globals.Errors.FAILED
	
	var offset := get_atlas_offset()
	
	for coords in get_coordinates_list():
		var template_coords = coords - offset
		if !template_bit_data.has_tile(template_coords):
			continue
		for bit in get_terrain_bits_list(true):
			var template_terrain_index := template_bit_data.get_bit_terrain(template_coords, bit)
			var terrain_index = terrain_mapping[template_terrain_index]
			set_bit_terrain(coords, bit, terrain_index)
	
	return Globals.Errors.OK



## Loads TileData into BitData resource; 
## p_tiles = Dict{coords : TileData}
func load_from_tile_data(p_tiles : Dictionary, p_tile_set : TileSet) -> Globals.Errors:
	# only allow loading into empty resource
	if has_data():
		return Globals.Errors.FAILED
	if p_tiles.size() == 0:
		return Globals.Errors.MISSING_TILES
	
	tile_set = p_tile_set
	
	var result := _load_tiles(p_tiles)
	return result
	
	
func _load_tiles(p_tiles : Dictionary) -> Globals.Errors:
	_print.user("Fetching current terrain bits now. Unassigned terrain bits will result in [i]Condition '!is_valid_terrain_peering_bit(p_peering_bit)' is true.[/i] Please ignore.")
	
	for coords in p_tiles.keys():
		_add_tile(coords)
		
		var tile_data : TileData = p_tiles[coords]
		if tile_data.terrain_set == NULL_TERRAIN_SET:
			# editor does not allow adding terrain without terrain set
			# so TileData will not have any terrain data
			continue
			
		var error := _load_terrain_set(tile_data)
		if error:
			return error
		
		_load_terrain(coords, tile_data)
	
	return Globals.Errors.OK
	

func _load_terrain_set(tile_data : TileData) -> Globals.Errors:
#	_print.debug("terrain_set=%s, TileData terrain_set=%s" % [terrain_set, tile_data.terrain_set])
	
	if terrain_set == NULL_TERRAIN_SET:
		terrain_set = tile_data.terrain_set
#		_print.debug("Assigning terrain_set => %s" % tile_data.terrain_set)
		terrain_mode = tile_set.get_terrain_set_mode(terrain_set)
		return Globals.Errors.OK
		
	if terrain_set != tile_data.terrain_set:
#		_print.debug("Multiple terrain sets")
		return Globals.Errors.MULTIPLE_TERRAIN_SETS

	return Globals.Errors.OK


# if a peering bit is unset, get_terrain_peering_bit() will cause error spam 
# of "!is_valid_terrain_peering_bit(p_peering_bit)" is true"
# TODO: request proposal
func _load_terrain(coords : Vector2i, tile_data : TileData) -> void:
	set_tile_terrain(coords, tile_data.terrain)
	
	for bit in get_terrain_bits_list():
		set_bit_terrain(coords, bit, tile_data.get_terrain_peering_bit(bit))

