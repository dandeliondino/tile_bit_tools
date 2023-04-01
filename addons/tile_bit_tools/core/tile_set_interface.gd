extends Object

const ItemDictList := preload("res://addons/tile_bit_tools/core/item_dict_list.gd")
const Icons := preload("res://addons/tile_bit_tools/core/icons.gd")


# {index : terrain_mode}
var terrain_sets := {}

# {terrain_set : [{
#	"index": terrain_index,
#	"color": color,
#	"name": name,
#},...]}
var terrains_by_set := {}

var tile_set : TileSet
var icons : Icons


func _init(p_tile_set : TileSet = null, p_icons : Icons = null) -> void:
	tile_set = p_tile_set
	icons = p_icons


func _update() -> void:
	if tile_set == null:
		return
	
	_populate_terrain_sets()
	_populate_terrains()



func _populate_terrain_sets() -> void:
	for i in range(tile_set.get_terrain_sets_count()):
		terrain_sets[i] = tile_set.get_terrain_set_mode(i)


func _populate_terrains() -> void:
	for terrain_set in terrain_sets.keys():
		terrains_by_set[terrain_set] = []
		for i in range(tile_set.get_terrains_count(terrain_set)):
			terrains_by_set[terrain_set].append({
				"id": i,
				"text": tile_set.get_terrain_name(terrain_set, i),
				"color": tile_set.get_terrain_color(terrain_set, i),
				"icon": get_terrain_icon(tile_set.get_terrain_color(terrain_set, i))
			})


func get_terrain_icon(color : Color) -> ImageTexture:
	var image := Image.create(16, 16, false, Image.FORMAT_RGB8)
	image.fill(color)
	return ImageTexture.create_from_image(image)


func get_terrain_sets() -> Array:
	return terrain_sets.keys()


func get_terrain_sets_by_mode(terrain_mode : TileSet.TerrainMode) -> Array:
	var terrain_set_list := []
	for index in terrain_sets.keys():
		if terrain_sets[index] == terrain_mode:
			terrain_set_list.append(index)
	return terrain_set_list


func get_terrain_sets_item_list(terrain_mode : TileSet.TerrainMode) -> Array:
	var terrain_set_list := []
	for index in terrain_sets.keys():
		if terrain_sets[index] == terrain_mode:
			terrain_set_list.append({
				"id": index,
				"terrain_mode": terrain_mode,
				"text": "[%s]" % [index],
				"icon": icons.get_icon(icons.TERRAIN_MODE_ICONS[terrain_mode]),
			})
	return terrain_set_list


func get_terrains_item_list(terrain_set : int) -> Array:
	return terrains_by_set[terrain_set]




