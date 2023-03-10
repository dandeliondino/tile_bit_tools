@tool
extends EditorInspectorPlugin


# DO NOT USE -INF/-INF == will evaluate as equal to Vector2i(0,0)
const INVALID_COORDINATES := Vector2i(-1, -1)

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")

var Context := preload("res://addons/tile_bit_tools/core/context.gd")
var SelectedTilesInspector := preload("res://addons/tile_bit_tools/controls/selected_tiles_inspector/selected_tiles_inspector.tscn")
var PreviewPanel := preload("res://addons/tile_bit_tools/controls/preview_panel/preview_panel.tscn")

var SharedNodesContainer := preload("res://addons/tile_bit_tools/controls/shared_nodes/shared_nodes_container.tscn")


var _print := preload("res://addons/tile_bit_tools/core/print.gd").new()

var controls := {}
var current_controls := []


# Editor nodes
var base_control : Control
var tile_set_editor : Node
var atlas_source_editor : Node
var tile_atlas_view : Node

# Proxy objects
# can get current source and selected tiles from their incoming connections
var atlas_source_proxy : Object
var atlas_tile_proxy : Object

var shared_nodes_container : Node

var context : Node
var tiles_inspector : Control
var tiles_preview : Control



# --------------------------------------
# 			SETUP
# --------------------------------------

func setup(interface : EditorInterface) -> Globals.Errors:
	base_control = interface.get_base_control()
	
	tile_set_editor = _get_first_node_by_class(interface.get_base_control(), "TileSetEditor")
	#_print.debug("tile_set_editor=%s" % tile_set_editor)
	if !tile_set_editor:
		return Globals.Errors.FAILED
	
	atlas_source_editor = _get_first_node_by_class(tile_set_editor, "TileSetAtlasSourceEditor")
	#_print.debug("atlas_source_editor=%s" % atlas_source_editor)
	if !atlas_source_editor:
		return Globals.Errors.FAILED
	var result := _setup_source_editor_button_connections()
#	if result != OK:
		#_print.error("_setup_source_editor_button_connections() failed", result)
		# do not return FAILED, not a breaking condition
#	else:
		#_print.debug("atlas_source_editor buttons connected")
	
	tile_atlas_view = _get_first_node_by_class(tile_set_editor, "TileAtlasView")
	#_print.debug("tile_atlas_view=%s" % tile_atlas_view)
	if !tile_atlas_view:
		return Globals.Errors.FAILED
	
	atlas_source_proxy = _get_first_connected_object_by_class(atlas_source_editor, "TileSetAtlasSourceProxyObject")
	#_print.debug("atlas_source_proxy=%s" % atlas_source_proxy)
	if !atlas_source_proxy:
		return Globals.Errors.FAILED
	
	atlas_tile_proxy = _get_first_connected_object_by_class(atlas_source_editor, "AtlasTileProxyObject")
	#_print.debug("atlas_tile_proxy=%s" % atlas_tile_proxy)
	if !atlas_tile_proxy:
		return Globals.Errors.FAILED
	
	var shared_node_result := _setup_shared_nodes()
	if shared_node_result != OK:
		return shared_node_result
	
	return Globals.Errors.OK


# Finds "Setup", "Select", "Paint" buttons and
# connects pressed to resetting inspector controls 
func _setup_source_editor_button_connections() -> Globals.Errors:
	var vbox := atlas_source_editor.get_child(0)
	if !vbox.is_class("VBoxContainer"):
		return Globals.Errors.FAILED
		
	var hbox := vbox.get_child(0)
	if !hbox.is_class("HBoxContainer"):
		return Globals.Errors.FAILED
		
	var buttons := hbox.get_children()
	for button in buttons:
		if !button.is_class("Button"):
			return Globals.Errors.FAILED
		button.pressed.connect(_clear_tiles_inspector)

	return Globals.Errors.OK


func _setup_shared_nodes() -> Globals.Errors:
	shared_nodes_container = SharedNodesContainer.instantiate()
	base_control.add_child(shared_nodes_container)
	_print.debug("shared nodes added")
	return Globals.Errors.OK


# --------------------------------------
# 			MAIN LOOP
# --------------------------------------

func _can_handle(object: Object) -> bool:
	_clear_tiles_inspector()
	
	if object.is_class("AtlasTileProxyObject"):
		_print.debug("_can_handle() => AtlasTileProxyObject")
		return true
	
	return false


func _parse_end(object: Object) -> void:
	if !object.is_class("AtlasTileProxyObject"):
		_print.warning("_parse_end(): object is not AtlasTileProxyObject, instead it is %s" % object)
		return
	
	var result := await _add_inspector()
	if result != OK:
#		_print.error("Inspector failed to add correctly, clearing remnants")
		_print.debug("TileSet inspector failed to open (ERR %s)" % result)
		_clear_tiles_inspector()
		return
	_print.debug("Inspector added without errors")




# --------------------------------------
# 		ADD INSPECTOR
# --------------------------------------


func _add_inspector() -> Globals.Errors:
	_print.debug("_add_inspector()")
	
	var result := await _add_context()
	if result != OK:
		return result
	
	_add_tiles_inspector()
		
	_add_tiles_preview()
	
	_notify_tiles_inspector_added()
	
	return Globals.Errors.OK



	

func _add_context() -> Globals.Errors:
	context = Context.new()
	
	context.base_control = base_control
	
	# Refresh to ensure not using stale references
	context.tile_set = _get_current_tile_set()
	if !context.tile_set:
		return Globals.Errors.MISSING_TILE_SET
		
	context.source = _get_current_source()
	if !context.source:
		return Globals.Errors.MISSING_SOURCE
	
	context.tiles = _get_current_tiles(context.source)
	if context.tiles.is_empty():
		return Globals.Errors.MISSING_TILES
	
	shared_nodes_container.add_child(context)
	if !context.ready_complete:
		await context.ready
	
	return context.finish_setup()


func _add_tiles_inspector() -> void:
	tiles_inspector = SelectedTilesInspector.instantiate()
	add_custom_control(tiles_inspector)


func _add_tiles_preview() -> void:
	# must await here
	# when tiles are re-selected, tiles_preview will not add
	# without first waiting for its prior instance to exit tree
	# BUT if await delays _add_tiles_inspector(),
	# add_custom_control() for tiles_inspector will fail silently
	await _wait_for_tree_exit(tiles_preview)
	tiles_preview = PreviewPanel.instantiate()
	tile_atlas_view.add_child(tiles_preview)



func _wait_for_tree_exit(node) -> void:
	if is_instance_valid(node):
		if node.is_queued_for_deletion():
			_print.debug("waiting for %s to leave tree" % node)
			await node.tree_exited
		else:
			_print.warning("%s not queued for deletion" % node)
			_clear_tiles_inspector()
			await node.tree_exited


# --------------------------------------
# 			CLEAN UP
# --------------------------------------

# Called from parent plugin when addon unloaded
func clean_up() -> void:
	_remove_shared_editor_nodes()
	_clear_tiles_inspector()
	# TODO
	pass


# Called when inspector data changed or focus moved away
func _clear_tiles_inspector() -> Globals.Errors:
	_print.debug("_clear_tiles_inspector()")
	if is_instance_valid(context):
		context.queue_free()
		_notify_tiles_inspector_removed()
	if is_instance_valid(tiles_inspector):
		tiles_inspector.queue_free()
	if is_instance_valid(tiles_preview):
		tiles_preview.queue_free()

	return Globals.Errors.OK


func _remove_shared_editor_nodes() -> void:
	if is_instance_valid(shared_nodes_container):
		shared_nodes_container.queue_free()
	_print.debug("shared editor nodes removed")






# --------------------------------------
# 	Helper functions
# --------------------------------------

func _get_current_tile_set() -> TileSet:
	return _get_first_connected_object_by_class(tile_set_editor, "TileSet")


func _get_current_source() -> TileSetAtlasSource:
	return _get_first_connected_object_by_class(atlas_source_proxy, "TileSetAtlasSource")


func _get_current_tiles(source : TileSetAtlasSource) -> Dictionary:
	var tiles := {}
	
	var tile_data_objects := _get_connected_objects_by_class(atlas_tile_proxy, "TileData")
	for tile_data in tile_data_objects:
		var coords := _find_coordinates_in_source(tile_data, source)
		if coords == INVALID_COORDINATES:
			_print.error("Unable to find tile in source")
			return {}
		tiles[coords] = tile_data

	return tiles


func _find_coordinates_in_source(tile_data : TileData, source : TileSetAtlasSource) -> Vector2i:
	for i in range(source.get_tiles_count()):
		var coords := source.get_tile_id(i)
		if tile_data == source.get_tile_data(coords, 0):
			return coords
	return INVALID_COORDINATES


func _get_first_node_by_class(parent_node : Node, p_class_name : String) -> Node:
	var nodes := parent_node.find_children("*", p_class_name, true, false)
	if !nodes.size():
		return null
	return nodes[0]


func _get_first_connected_object_by_class(object : Object, p_class_name : String) -> Object:
	var objects := _get_connected_objects_by_class(object, p_class_name)
	if !objects.size():
		return null
	return objects[0]


func _get_connected_objects_by_class(object : Object, p_class_name : String) -> Array:
	var objects := []
	for connection in object.get_incoming_connections():
		var connected_object = connection["signal"].get_object()
		if connected_object.is_class(p_class_name):
			objects.append(connected_object)
	return objects


func _notify_tiles_inspector_added() -> void:
	if is_instance_valid(shared_nodes_container):
		shared_nodes_container.notify_tiles_inspector_added(context)


func _notify_tiles_inspector_removed() -> void:
	if is_instance_valid(shared_nodes_container):
		shared_nodes_container.notify_tiles_inspector_removed()

