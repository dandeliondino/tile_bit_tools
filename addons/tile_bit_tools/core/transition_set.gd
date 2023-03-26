@tool
extends Object
## TransitionSet

const NULL_TERRAIN_SET := -99
const NULL_TERRAIN_ID := -99
const NULL_PEERING_TERRAIN_IDS := []
const NULL_SOURCE_ID := -1

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

const BitData := preload("res://addons/tile_bit_tools/core/bit_data.gd")

var output := preload("res://addons/tile_bit_tools/core/output.gd").new()

class TileLocation:
	var source_id : int
	var coords : Vector2i
	
	func _init(p_source_id := NULL_SOURCE_ID, p_coords := Vector2i.ZERO) -> void:
		source_id = p_source_id
		coords = p_coords

var mode : TileSet.TerrainMode
var terrain_set : int
var terrain_id : int
var peering_terrain_ids := []

# _tiles[index] = [TileLocation, ...]
var _tiles : Dictionary

# Contains the base tiles for terrain_id and peering_terrain_ids
# Used for plain tiles where all bits are set to center terrain_id
# _base_tiles[terrain_id] = [TileLocation, ...]
var _base_tiles : Dictionary

var id : String


func _init(p_terrain_set := NULL_TERRAIN_SET, p_mode := TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES, p_terrain_id := NULL_TERRAIN_ID, p_peering_terrain_ids := NULL_PEERING_TERRAIN_IDS) -> void:
	mode = p_mode
	terrain_set = p_terrain_set
	terrain_id = p_terrain_id
	peering_terrain_ids = p_peering_terrain_ids
	peering_terrain_ids.sort()
	id = get_transition_set_id(terrain_id, peering_terrain_ids)
	_setup_base_tiles()
	_setup_tiles()


func _setup_base_tiles() -> void:
	_base_tiles = {}
	_base_tiles[terrain_id] = []
	for peering_terrain_id in peering_terrain_ids:
		_base_tiles[peering_terrain_id] = []


func _setup_tiles() -> void:
	_tiles = {}
	for index in TilesByMode[mode]:
		_tiles[index] = []


func add_tile(tile_bits : BitData.TileBits, tile_location : TileLocation) -> void:
	if tile_bits.terrain_id != terrain_id:
		output.error("Attempted to add tile of non-matching terrain_id to TransitionSet")
		return
	if tile_bits.is_base_tile():
		output.error("Attempted to add base tile as a non-base tile to TransitionSet")
		return
	
	var index := _get_tile_index(tile_bits)
	print(index)
	if !_tiles.has(index):
		output.error("Attempted to add tile of invalid index")
		return
	
	_tiles[index].append(tile_location)
	
	

func add_base_tile(p_terrain_id : int, tile_location : TileLocation) -> void:
	if !has_terrain(p_terrain_id):
		output.error("Attempted to add base tile of non-matching terrain_id to TransitionSet")
		return
	_base_tiles[p_terrain_id].append(tile_location)


static func get_transition_set_id(p_terrain_id := NULL_TERRAIN_ID, p_peering_terrain_ids := NULL_PEERING_TERRAIN_IDS) -> String:
	return "%s_to_%s" % [p_terrain_id, "_".join(p_peering_terrain_ids)]


# TODO: set these up at beginning so don't have to repeat
func get_used_indexes() -> Array:
	var indexes := []
	for index in _tiles.keys():
		if _tiles[index].size() == 0:
			continue
		indexes.append(index)
	return indexes


func get_empty_indexes() -> Array:
	var indexes := []
	for index in _tiles.keys():
		if _tiles[index].size() > 0:
			continue
		indexes.append(index)
	return indexes


func get_tile_locations_at_index(index : int) -> Array:
	return _tiles[index]


func get_tiles() -> Dictionary:
	return _tiles

func has_terrain(p_terrain_id : int) -> bool:
	if terrain_id == p_terrain_id:
		return true
	if p_terrain_id in peering_terrain_ids:
		return true
	return false


func print_tiles() -> void:
	output.debug("TransitionSet=%s" % id)
	output.debug("Base tiles:")
	for base_terrain_id in _base_tiles.keys():
		output.debug("\tterrain %s => %s" % [base_terrain_id, _get_location_string(_base_tiles[base_terrain_id])])
	output.debug("Tiles:")
	for index in _tiles.keys():
		output.debug("\t%s => %s" % [index, _get_location_string(_tiles[index])])


func _get_location_string(locations_list : Array) -> String:
		var location_strings := []
		for loc in locations_list:
			location_strings.append("%s : (%s, %s)" % [loc.source_id, loc.coords.x, loc.coords.y])
		return ", ".join(location_strings)


# TODO: will need to be updated for > 2 terrains
func _get_tile_index(tile_bits : BitData.TileBits) -> int:
	var index := 0
	for bit in tile_bits.get_bits_list():
		var bit_terrain_id := tile_bits.get_bit_terrain_id(bit)
		if bit_terrain_id == terrain_id:
			index += TerrainBitWeights[bit]
	return index









