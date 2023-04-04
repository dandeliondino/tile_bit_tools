@tool
extends Control

signal tile_set_changed

signal tiles_selected(selection_context)

signal tiles_inspector_added
signal tiles_inspector_removed

signal templates_updated
signal templates_update_requested

signal save_template_requested
signal edit_template_requested(template_bit_data)
signal message_box_requested(msg)

signal preview_updated(preview_bit_data)
signal reset_requested
signal apply_changes_requested

signal tiles_preview_collapse_requested
signal tiles_preview_expand_requested

signal theme_update_requested(node)


enum PluginState {
	LOADING,
	RUNNING,
	EXITING,
}

# EditorNode is reserved name
enum EditorTreeNode {
	BASE_CONTROL,
	TILE_SET_EDITOR, 
	ATLAS_SOURCE_EDITOR, 
	TILE_ATLAS_VIEW,
}

enum TBTNode {
	TILES_INSPECTOR,
	TILES_PREVIEW,
}





const TBT_PROPERTY_NAME := "tbt"
const TBT_READY_METHOD := "_tbt_ready"
const TILES_INSPECTOR_ADDED_METHOD := "_tiles_inspector_added"
const TILES_INSPECTOR_REMOVED_METHOD := "_tiles_inspector_removed"

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
const Texts := preload("res://addons/tile_bit_tools/core/texts.gd")
const Icons := preload("res://addons/tile_bit_tools/core/icons.gd")
const Output := preload("res://addons/tile_bit_tools/core/output.gd")

const TileSetInterface := preload("res://addons/tile_bit_tools/core/tile_set_interface.gd")

const DataLayer := preload("res://addons/tile_bit_tools/core/data_layer.gd")

const BitData := preload("res://addons/tile_bit_tools/core/bit_data.gd")
const EditorBitData := preload("res://addons/tile_bit_tools/core/editor_bit_data.gd")
const TemplateBitData := preload("res://addons/tile_bit_tools/core/template_bit_data.gd")

const TemplateManager := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/template_manager.gd")
const TilesManager := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tiles_manager.gd")
const ThemeUpdater := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/theme_updater.gd")

const Context := preload("res://addons/tile_bit_tools/core/context.gd")
const SelectionContext := preload("res://addons/tile_bit_tools/core/selection_context.gd")


const TreeUtils := preload("res://addons/tile_bit_tools/core/tree_utils.gd")

# Proxy objects
# can get current source and selected tiles from their incoming connections
var editor_source_proxy : Object
var editor_tile_proxy : Object


var output : Output = Output.new()
var texts : Texts = Texts.new()
var icons : Icons

var interface : EditorInterface
var _editor_nodes := {}

var context : Context

var current_tile_set : TileSet
var current_source : TileSetSource
var tile_set_interface : TileSetInterface

var _tbt_nodes_to_reparent := {
	TBTNode.TILES_PREVIEW: EditorTreeNode.TILE_ATLAS_VIEW,
}

var _tiles_inspector : Control :
	get:
		return _tbt_nodes[TBTNode.TILES_INSPECTOR]

var _tiles_preview : Control :
	get:
		return _tbt_nodes[TBTNode.TILES_PREVIEW]


@onready var template_manager: TemplateManager = %TemplateManager
@onready var tiles_manager: TilesManager = %TilesManager
@onready var theme_updater: ThemeUpdater = %ThemeUpdater

# iterate to queue_free() when cleaning up
@onready var _tbt_nodes := {
	TBTNode.TILES_PREVIEW: %TilesPreview,
	TBTNode.TILES_INSPECTOR: %TilesInspector,
}



@onready var nodes_to_clean_up := _tbt_nodes.values() + [
		# add any additional nodes to clean up here
	]

@onready var save_template_dialog: Window = %SaveTemplateDialog
@onready var edit_template_dialog: Window = %EditTemplateDialog

# iterate to determine if any are visible
@onready var _dialog_windows := [
	save_template_dialog,
	edit_template_dialog,
]

var state := PluginState.LOADING :
	set(value):
		state = value
		output.debug("plugin state=%s" % value)

var ready_complete := false


# ------------------------------------------------------------------------
#		SETUP
# ------------------------------------------------------------------------

func _ready() -> void:
	set_process_input(false)
	ready_complete = true


func setup(p_interface : EditorInterface) -> Globals.Errors:
	_setup_debug_signals()
	
	interface = p_interface
	var result := _update_editor_references()
	if result != OK:
		return result
	
	icons = Icons.new(get_editor_node(EditorTreeNode.BASE_CONTROL))
	
	_inject_tbt_reference(self)
	
	for node_id in _tbt_nodes_to_reparent.keys():
		_reparent_tbt_node(node_id)
	
	# for testing only
	_tiles_preview.show()
	
	state = PluginState.RUNNING
	
	return Globals.Errors.OK


func _on_tbt_node_tree_exiting(node_name : String) -> void:
	if state == PluginState.EXITING:
		return
	output.warning("TBT Node exiting tree: %s" % node_name)


func _reparent_tbt_node(tbt_node : TBTNode) -> Globals.Errors:
	var node := get_tbt_node(tbt_node)
	var parent := get_editor_node(_tbt_nodes_to_reparent[tbt_node])
	if !node or !parent:
		output.debug("Failed to add TBTNode %s to %s" % [node, parent])
		return Globals.Errors.FAILED
	node.reparent(parent, false)
	output.debug("Reparented TBTNode %s to %s" % [node, parent])
	
	node.tree_exiting.connect(_on_tbt_node_tree_exiting.bind(node.name))
	
	return Globals.Errors.OK





# ------------------------------------------------------------------------
#		CLEAN UP
# ------------------------------------------------------------------------

func clean_up() -> void:
	output.debug("tbt.clean_up()")
	state = PluginState.EXITING
	for node in nodes_to_clean_up:
		if is_instance_valid(node):
			output.debug("freeing %s" % node)
			node.queue_free()



# ------------------------------------------------------------------------
#		PUBLIC FUNCTIONS
# ------------------------------------------------------------------------


func get_editor_node(editor_node : EditorTreeNode) -> Node:
	return _editor_nodes.get(editor_node, null)


func get_tbt_node(tbt_node : TBTNode) -> Node:
	return _tbt_nodes.get(tbt_node, null)


func get_tiles_inspector() -> Control:
	remove_child(_tiles_inspector)
	return _tiles_inspector

	
#func notify_tiles_inspector_added(p_tiles_inspector : Control) -> void:
#	tiles_inspector = p_tiles_inspector
#	_inject_tbt_reference(tiles_inspector, true)
#	TreeUtils.call_subtree(self, TILES_INSPECTOR_ADDED_METHOD)
#	tiles_inspector_added.emit()
#	tiles_inspector.visibility_changed.connect(_on_tiles_inspector_visibility_changed)
#	_setup_dynamic_containers()
#	set_process_input(true)
#	tiles_preview_expand_requested.emit()


#func notify_tiles_inspector_removed() -> void:
#	set_process_input(false)
#	TreeUtils.call_subtree(self, TILES_INSPECTOR_REMOVED_METHOD)
#	tiles_inspector_removed.emit()


func is_dialog_popped_up() -> bool:
	for dialog in _dialog_windows:
		if dialog.visible:
			return true
	return false


func _setup_dynamic_containers() -> void:
	for node in get_tree().get_nodes_in_group(Globals.GROUP_DYNAMIC_CONTAINER):
		if !node.child_entered_tree.is_connected(_on_dynamic_container_child_added):
			node.child_entered_tree.connect(_on_dynamic_container_child_added)


func _on_dynamic_container_child_added(node : Node) -> void:
	_inject_tbt_reference(node, true)
	theme_update_requested.emit(node)


#func _on_tiles_inspector_visibility_changed() -> void:
#	if !is_instance_valid(tiles_inspector) or !tiles_inspector.is_visible_in_tree():
#		_tiles_preview.hide()
#		set_process_input(false)
#	else:
#		_tiles_preview.show()
#		set_process_input(true)


# while tiles inspector is visible, watch for mouse clicks and 
# collapse preview panel for clicks outside of this plugin
#func _input(event: InputEvent) -> void:
#	if not event is InputEventMouseButton:
#		return
#	if not event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
#		return
#
#	if is_dialog_popped_up():
#		return
#
#	var mouse_position = get_global_mouse_position()
#
#	if tiles_inspector.get_parent_control().get_global_rect().has_point(mouse_position):
#		if tiles_inspector.get_global_rect().has_point(mouse_position):
#			if !_tiles_preview.expanded:
#				tiles_preview_expand_requested.emit()
#		else:
#			tiles_preview_collapse_requested.emit()
#		return
#
#	if !_tiles_preview.expanded:
#		return
#
#	if _tiles_preview.get_parent_control().get_global_rect().has_point(mouse_position):
#		if !_tiles_preview.get_mouse_input_rect().has_point(mouse_position):
#			tiles_preview_collapse_requested.emit()
#











# ------------------------------------------------------------------------
#		INJECTIONS
# ------------------------------------------------------------------------

func _inject_tbt_reference(node : Node, include_parent := false) -> void:
	TreeUtils.set_subtree(node, TBT_PROPERTY_NAME, self, include_parent)
	TreeUtils.call_subtree(node, TBT_READY_METHOD, include_parent)


# ------------------------------------------------------------------------
#		NODE MANAGEMENT
# ------------------------------------------------------------------------

func _update_editor_references() -> Globals.Errors:
	_editor_nodes = {}
	
	var base_control := interface.get_base_control()
	_editor_nodes[EditorTreeNode.BASE_CONTROL] = base_control
	
	var tile_set_editor := TreeUtils.get_first_node_by_class(base_control, "TileSetEditor")
	if !tile_set_editor:
		return Globals.Errors.EDITOR_NODE_NOT_FOUND
	_editor_nodes[EditorTreeNode.TILE_SET_EDITOR] = tile_set_editor

	var atlas_source_editor := TreeUtils.get_first_node_by_class(tile_set_editor, "TileSetAtlasSourceEditor")
	if !atlas_source_editor:
		return Globals.Errors.EDITOR_NODE_NOT_FOUND
	_editor_nodes[EditorTreeNode.ATLAS_SOURCE_EDITOR] = atlas_source_editor
	
	var tile_atlas_view := TreeUtils.get_first_node_by_class(tile_set_editor, "TileAtlasView")
	if !tile_atlas_view:
		return Globals.Errors.EDITOR_NODE_NOT_FOUND
	_editor_nodes[EditorTreeNode.TILE_ATLAS_VIEW] = tile_atlas_view
	
	editor_source_proxy = TreeUtils.get_first_connected_object_by_class(atlas_source_editor, "TileSetAtlasSourceProxyObject")
	if !editor_source_proxy:
		return Globals.Errors.FAILED
	editor_source_proxy.property_list_changed.connect(_on_tile_set_source_changed)
	
	editor_tile_proxy = TreeUtils.get_first_connected_object_by_class(atlas_source_editor, "AtlasTileProxyObject")
	if !editor_tile_proxy:
		return Globals.Errors.FAILED
	editor_tile_proxy.property_list_changed.connect(_on_tile_selection_changed)

	return Globals.Errors.OK



# ------------------------------------------------------------------------
#		UPDATES
# ------------------------------------------------------------------------


func update_tile_set_and_source() -> void:
	var new_tile_set := TreeUtils.get_first_connected_object_by_class(get_editor_node(EditorTreeNode.TILE_SET_EDITOR), "TileSet")
	if current_tile_set != new_tile_set:
		current_tile_set = new_tile_set
		tile_set_interface = TileSetInterface.new(new_tile_set, icons)
		output.debug("Changed TileSet to %s (TerrainSets=%s, Terrains=%s)" % [
			new_tile_set, 
			tile_set_interface.terrain_set_list.size(), 
			tile_set_interface.terrain_list.size()
		])
		tile_set_changed.emit()
	
	current_source = TreeUtils.get_first_connected_object_by_class(editor_source_proxy, "TileSetAtlasSource")






# ------------------------------------------------------------------------
#		HELPER FUNCTIONS
# ------------------------------------------------------------------------





# ------------------------------------------------------------------------
#		DEBUG SIGNALS
# ------------------------------------------------------------------------

func _setup_debug_signals() -> void:
	for signal_data in get_signal_list():
		if signal_data.args.size() == 0:
			connect(signal_data.name, _on_signal_emitted.bind(signal_data.name))
		else:
			connect(signal_data.name, _on_signal_emitted_with_arg.bind(signal_data.name))


func _on_signal_emitted(signal_name := "") -> void:
	output.debug("[TBTPlugin] Signal emitted: %s" % signal_name)


func _on_signal_emitted_with_arg(arg = null, signal_name := "") -> void:
	output.debug("[TBTPlugin] Signal emitted: %s (%s)" % [signal_name, arg])



# ------------------------------------------------------------------------
#		SIGNALS
# ------------------------------------------------------------------------


func _on_tile_set_source_changed() -> void:
	output.debug("TBT: _on_tile_set_source_changed()")
	update_tile_set_and_source()


# when new tiles are selected, the editor inspector clears its children
# if _tiles_inspector is reparented at the time of this signal,
# can be saved for reuse
func _on_tile_selection_changed() -> void:
	output.debug("TBT: _on_tile_selection_changed()")
	_tiles_inspector.reparent(self)

