@tool
extends EditorInspectorPlugin

# Do not use Vector2i(-INF/-INF) - will evaluate as equal to Vector2i(0,0)
const INVALID_COORDINATES := Vector2i(-1, -1)

const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")


var tbt : TBTPlugin


# --------------------------------------
# 			SETUP
# --------------------------------------

func setup(p_tbt : TBTPlugin) -> void:
	tbt = p_tbt







# --------------------------------------
# 			MAIN LOOP
# --------------------------------------

func _can_handle(object: Object) -> bool:
	if object.is_class("AtlasTileProxyObject"):
		tbt.output.debug("_can_handle() => AtlasTileProxyObject")
		return true
	return false


func _parse_end(object: Object) -> void:
	if !object.is_class("AtlasTileProxyObject"):
		tbt.output.warning("_parse_end(): object is not AtlasTileProxyObject, instead it is %s" % object)
		return
	
	var selected_tiles := _get_selected_tiles()
	if selected_tiles.size() == 0:
		return
		
	_add_tiles_inspector()




# --------------------------------------
# 		ADD INSPECTOR
# --------------------------------------


func _add_tiles_inspector() -> void:
	var tiles_inspector := tbt.get_tiles_inspector()
	add_custom_control(tiles_inspector)
	tiles_inspector.visible = true



	

#func _add_context() -> Globals.Errors:
#	context = Context.new()
#
#	context.base_control = base_control
#
#	# Refresh to ensure not using stale references
#	context.tile_set = _get_current_tile_set()
#	if !context.tile_set:
#		return Globals.Errors.MISSING_TILE_SET
#
#	context.source = _get_current_source()
#	if !context.source:
#		return Globals.Errors.MISSING_SOURCE
#
#	context.tiles = _get_current_tiles(context.source)
#	if context.tiles.is_empty():
#		return Globals.Errors.MISSING_TILES
#
#	tbt_plugin_control.add_child(context)
#	if !context.ready_complete:
#		await context.ready
#
#	return context.finish_setup()










# --------------------------------------
# 	Helper functions
# --------------------------------------



func _get_selected_tiles() -> Dictionary:
	var tiles := {}
	
	tbt.update_tile_set_and_source()
	
	var tile_data_objects := tbt.TreeUtils.get_connected_objects_by_class(tbt.editor_tile_proxy, "TileData")
	for tile_data in tile_data_objects:
		var coords := _find_coordinates_in_source(tile_data, tbt.current_source)
		if coords == INVALID_COORDINATES:
			tbt.output.error("Unable to find tile in source")
			return {}
		tiles[coords] = tile_data

	return tiles


func _find_coordinates_in_source(tile_data : TileData, source : TileSetAtlasSource) -> Vector2i:
	for i in range(source.get_tiles_count()):
		var coords := source.get_tile_id(i)
		if tile_data == source.get_tile_data(coords, 0):
			return coords
	return INVALID_COORDINATES



