extends RefCounted

const ItemDictList := preload("res://addons/tile_bit_tools/core/item_dict_list.gd")
const Icons := preload("res://addons/tile_bit_tools/core/icons.gd")

var terrain_set_list := ItemDictList.new()
var terrain_list := ItemDictList.new()

var tile_set : TileSet
var icons : Icons


func _init(p_tile_set : TileSet = null, p_icons : Icons = null) -> void:
	tile_set = p_tile_set
	icons = p_icons

	if tile_set == null:
		return
	
	_populate_terrain_sets()
	_populate_terrains()


func _populate_terrain_sets() -> void:
	for id in tile_set.get_terrain_sets_count():
		var terrain_mode := tile_set.get_terrain_set_mode(id)
		var icon := icons.get_icon(icons.TERRAIN_MODE_ICONS[terrain_mode])
		terrain_set_list.add_item(id, "[%s]" % id, icon)
		terrain_set_list.set_item_key(id, "TERRAIN_MODE", terrain_mode)


func _populate_terrains() -> void:
	for terrain_set in tile_set.get_terrain_sets_count():
		for id in tile_set.get_terrains_count(terrain_set):
			var text := tile_set.get_terrain_name(terrain_set, id)
			var color := tile_set.get_terrain_color(terrain_set, id)
			var icon := _get_terrain_icon(color)
			terrain_list.add_item(id, text, icon)
			terrain_list.set_item_key(id, "COLOR", color)


func _get_terrain_icon(color : Color) -> ImageTexture:
	var image := Image.create(16, 16, false, Image.FORMAT_RGB8)
	image.fill(color)
	return ImageTexture.create_from_image(image)





