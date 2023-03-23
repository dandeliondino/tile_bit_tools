@tool
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
	

# TODO: update to support alternative tiles
func setup_from_tile_set(tile_set : TileSet) -> void:
	transition_sets = {}
	base_tiles = {}
	
	for source_id in range(tile_set.get_source_count()):
		if not tile_set.get_source(source_id) is TileSetAtlasSource:
			print("source is not atlas source")
			continue
		var source : TileSetAtlasSource = tile_set.get_source(source_id)
		print("source=%s" % source)
		for tile_index in range(source.get_tiles_count()):
			var coords := source.get_tile_id(tile_index) 
			print("evaluating tile at coords=%s" % coords)
			var tile_data := source.get_tile_data(coords, 0)
			var terrain_set := tile_data.terrain_set
			if terrain_set < 0:
				continue
			
			# TODO: move global mode inside function
			var terrain_mode = tile_set.get_terrain_set_mode(terrain_set)
			var bits_dict := {}
			for bit in BitData.CellNeighborsByMode[terrain_mode]:
				bits_dict[bit] = tile_data.get_terrain_peering_bit(bit)
				
			var tile_bits := BitData.TileBits.new(tile_data.terrain, bits_dict)
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
	print("print_tiles")
	for transition_set in transition_sets.values():
		transition_set.print_tiles()

