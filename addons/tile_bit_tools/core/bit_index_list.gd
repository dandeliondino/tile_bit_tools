extends Resource

const BitData := preload("res://addons/tile_bit_tools/core/bit_data.gd")

var TilesByMode := {
	TileSet.TERRAIN_MODE_MATCH_SIDES: [],
	TileSet.TERRAIN_MODE_MATCH_CORNERS: [],
	TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES: [0, 1, 4, 5, 7, 16, 17, 20, 21, 23, 28, 29, 31, 64, 65, 68, 69, 71, 80, 81, 84, 85, 87, 92, 93, 95, 112, 113, 116, 117, 119, 124, 125, 127, 193, 197, 199, 209, 213, 215, 221, 223, 241, 245, 247, 253],
}


var TerrainBitWeights := {
	TileSet.CELL_NEIGHBOR_TOP_SIDE: 1,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER: 2,
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE: 4,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER: 8,
	TileSet.CELL_NEIGHBOR_BOTTOM_SIDE: 16,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER: 32,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE: 64,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER: 128,
}


# transition_sets = {
#		"transition_set_id": {
#			"terrain_id": terrain_id,
#			"peering_terrain_ids": [terrain_id, ...],
#			"tiles": {},
#	}
# }

# transition_sets
var transition_sets := {}



func _get_transition_set_id(terrain_id : int, peering_terrain_ids : Array) -> String:
	if peering_terrain_ids.size() == 0:
		return str(terrain_id)
	
	peering_terrain_ids.sort()
	return "%s__%s" % [terrain_id, "_".join(peering_terrain_ids)]


func _get_or_add_transition_set(terrain_id : int, peering_terrain_ids : Array) -> String:
	var transition_set_id := _get_transition_set_id(terrain_id, peering_terrain_ids)
	if !transition_sets.has(transition_set_id):
		transition_sets[transition_set_id] = {
			"terrain_id": terrain_id,
			"peering_terrain_ids": peering_terrain_ids,
			"tiles": {},
		}
	return transition_set_id


func setup_from_bit_data(bit_data : BitData) -> void:
	transition_sets.clear()
	
	for coords in bit_data.get_coordinates_list():
		var terrain_id := bit_data.get_tile_terrain(coords)
		var peering_terrains : Array = bit_data.get_tile_peering_terrains(coords)
		var transition_set_id := _get_or_add_transition_set(terrain_id, peering_terrains)
		var tile_index := _get_bitwise_index(terrain_id, bit_data.get_tile_bits_dict(coords))
		transition_sets[transition_set_id].tiles[tile_index] = coords
		

func _get_bitwise_index(terrain_id : int, tile_bits_dict : Dictionary) -> int:
	var index := 0
	for bit in tile_bits_dict.keys():
		if tile_bits_dict[bit] == terrain_id:
			index += TerrainBitWeights[bit]
	return index


func get_terrain_tiles_list(transition_set_id : String) -> Array:
	var tiles_list : Array = transition_sets[transition_set_id].tiles.keys().duplicate()
	tiles_list.sort()
	return tiles_list


func print_tiles() -> void:
	for transition_set_id in transition_sets.keys():
		print()
		print("transition_set_id=%s" % transition_set_id)
		print(get_terrain_tiles_list(transition_set_id))
		print("is_set_complete()=%s" % is_set_complete(transition_set_id))
		print()


func is_set_complete(transition_set_id : String) -> bool:
	var tiles_list := get_terrain_tiles_list(transition_set_id)
	for index in TilesByMode[TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES]:
		if not index in tiles_list:
			return false
	return true
