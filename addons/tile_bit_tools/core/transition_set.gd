extends Object
## TransitionSet

const NULL_TERRAIN_ID := -99
const NULL_PEERING_TERRAIN_IDS := []

const TilesByMode := {
	TileSet.TERRAIN_MODE_MATCH_SIDES: [],
	TileSet.TERRAIN_MODE_MATCH_CORNERS: [],
	TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES: [0, 1, 4, 5, 7, 16, 17, 20, 21, 23, 28, 29, 31, 64, 65, 68, 69, 71, 80, 81, 84, 85, 87, 92, 93, 95, 112, 113, 116, 117, 119, 124, 125, 127, 193, 197, 199, 209, 213, 215, 221, 223, 241, 245, 247, 253],
}


const TerrainBitWeights := {
	TileSet.CELL_NEIGHBOR_TOP_SIDE: 1,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER: 2,
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE: 4,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER: 8,
	TileSet.CELL_NEIGHBOR_BOTTOM_SIDE: 16,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER: 32,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE: 64,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER: 128,
}


class TileLocation:
	var source_id : int
	var coords : Vector2i

var terrain_id : int
var peering_terrain_ids := []

# _tiles[index] = [TileLocation]
var _tiles := {}

# Contains the base tiles for terrain_id and peering_terrain_ids
# Used for plain tiles where all bits are set to center terrain_id
# _base_tiles[terrain_id] = [TileLocation]
var _base_tiles := {}

var id : String


func _init(p_terrain_id := NULL_TERRAIN_ID, p_peering_terrain_ids := NULL_PEERING_TERRAIN_IDS) -> void:
	terrain_id = p_terrain_id
	peering_terrain_ids = p_peering_terrain_ids
	peering_terrain_ids.sort()
	id = get_transition_set_id(terrain_id, peering_terrain_ids)


static func get_transition_set_id(p_terrain_id := NULL_TERRAIN_ID, p_peering_terrain_ids := NULL_PEERING_TERRAIN_IDS) -> String:
	return "%s_to_%s" % [p_terrain_id, "_".join(p_peering_terrain_ids)]


# TODO: will need to be updated for > 2 terrains
func _get_tile_index(terrain_id : int, tile_bits_dict : Dictionary) -> int:
	var index := 0
	for bit in tile_bits_dict.keys():
		if tile_bits_dict[bit] == terrain_id:
			index += TerrainBitWeights[bit]
	return index









