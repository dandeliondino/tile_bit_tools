extends Resource

const BitData := preload("res://addons/tile_bit_tools/core/bit_data.gd")
const TransitionSet := preload("res://addons/tile_bit_tools/core/transition_set.gd")


var mode : TileSet.TerrainMode

# transition_sets[transition_set_id] = TransitionSet
var transition_sets : Dictionary

# base_tiles[terrain_id] = [TileLocation, ...]
var base_tiles : Dictionary



func _get_transition_set(tile_bits : BitData.TileBits) -> TransitionSet:
	var transition_set_id := TransitionSet.get_transition_set_id(tile_bits.terrain_id, tile_bits.peering_terrain_ids)
	var transition_set : TransitionSet
	
	if transition_sets.has(transition_set_id):
		transition_set = transition_sets[transition_set_id]
	else:
		transition_set = TransitionSet.new(tile_bits.terrain_id, tile_bits.peering_terrain_ids, mode)
		transition_sets[transition_set_id] = transition_set
	return transition_set


func setup_from_bit_data(bit_data : BitData, source_id := -1) -> void:
	transition_sets = {}
	base_tiles = {}
	mode = bit_data.terrain_mode

	for coords in bit_data.get_coordinates_list():
		var tile_bits := bit_data.get_tile_bits(coords)
		var tile_location := TransitionSet.TileLocation.new(source_id, coords)
		
		if tile_bits.is_base_tile():
			_add_base_tile(tile_bits, tile_location)
			continue
		
		var transition_set := _get_transition_set(tile_bits)
		transition_set.add_tile(tile_bits, tile_location)
	
	_distribute_base_tiles()
	


func _add_base_tile(tile_bits : BitData.TileBits, tile_location : TransitionSet.TileLocation) -> void:
		if !base_tiles.has(tile_bits.terrain_id):
			base_tiles[tile_bits.terrain_id] = []
		base_tiles[tile_bits.terrain_id].append(tile_location)


func _distribute_base_tiles() -> void:
	for transition_set in transition_sets.values():
		for terrain_id in base_tiles.keys():
			if transition_set.has_terrain(terrain_id):
				for tile_location in base_tiles[terrain_id]:
					transition_set.add_base_tile(terrain_id, tile_location)


func print_tiles() -> void:
	for transition_set in transition_sets.values():
		transition_set.print_tiles()


#
#func _get_bitwise_index(terrain_id : int, tile_bits_dict : Dictionary) -> int:
#	var index := 0
#	for bit in tile_bits_dict.keys():
#		if tile_bits_dict[bit] == terrain_id:
#			index += TerrainBitWeights[bit]
#	return index
#
#
#func get_terrain_tiles_list(transition_set_id : String) -> Array:
#	var tiles_list : Array = transition_sets[transition_set_id].tiles.keys().duplicate()
#	tiles_list.sort()
#	return tiles_list
#
#
#func print_tiles() -> void:
#	for transition_set_id in transition_sets.keys():
#		print()
#		print("transition_set_id=%s" % transition_set_id)
#		print(get_terrain_tiles_list(transition_set_id))
#		print("is_set_complete()=%s" % is_set_complete(transition_set_id))
#		print()
#
#
#func is_set_complete(transition_set_id : String) -> bool:
#	var tiles_list := get_terrain_tiles_list(transition_set_id)
#	for index in TilesByMode[TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES]:
#		if not index in tiles_list:
#			return false
#	return true
