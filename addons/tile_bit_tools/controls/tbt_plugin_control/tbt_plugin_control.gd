@tool
extends Control


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
	SELECTED_TILES_INSPECTOR_VBOX,
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

const BitData := preload("res://addons/tile_bit_tools/core/bit_data.gd")
const EditorBitData := preload("res://addons/tile_bit_tools/core/editor_bit_data.gd")
const TemplateBitData := preload("res://addons/tile_bit_tools/core/template_bit_data.gd")

const TemplateManager := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/template_manager.gd")
const TilesManager := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tiles_manager.gd")
const ThemeUpdater := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/theme_updater.gd")
const Context := preload("res://addons/tile_bit_tools/core/context.gd")

var _atlas_source_proxy : Object
var _atlas_tile_proxy : Object



var output : Output = Output.new()
var texts : Texts = Texts.new()
var icons : Icons

var interface : EditorInterface
var _editor_nodes := {}

var context : Context


var _tbt_node_parents := {
	TBTNode.TILES_INSPECTOR: EditorTreeNode.SELECTED_TILES_INSPECTOR_VBOX,
	TBTNode.TILES_PREVIEW: EditorTreeNode.TILE_ATLAS_VIEW,
}

var current_tile_set : TileSet
var current_source : TileSetSource


@onready var template_manager: TemplateManager = %TemplateManager
@onready var tiles_manager: TilesManager = %TilesManager
@onready var theme_updater: ThemeUpdater = %ThemeUpdater

# iterate to queue_free() when cleaning up
@onready var _tbt_nodes := {
	TBTNode.TILES_INSPECTOR: %TilesInspector,
	TBTNode.TILES_PREVIEW: %TilesPreview,
}

var tiles_inspector : Control :
	get:
		return _tbt_nodes[TBTNode.TILES_INSPECTOR]

var tiles_preview : Control :
	get:
		return _tbt_nodes[TBTNode.TILES_PREVIEW]


@onready var save_template_dialog: Window = %SaveTemplateDialog
@onready var edit_template_dialog: Window = %EditTemplateDialog

# iterate to determine if any are visible
@onready var _dialog_windows := [
	save_template_dialog,
	edit_template_dialog,
]

var state := PluginState.LOADING

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
	
	for node_id in _tbt_node_parents.keys():
		_reparent_tbt_node(node_id)
	
	# for testing only
	tiles_inspector.show()
	tiles_preview.show()
	
	state = PluginState.RUNNING
	
	return Globals.Errors.OK


func _on_tbt_node_tree_exiting(node_name : String) -> void:
	if state == PluginState.EXITING:
		return
	output.warning("TBT Node exiting tree: %s" % node_name)


func _reparent_tbt_node(tbt_node : TBTNode) -> Globals.Errors:
	var node := get_tbt_node(tbt_node)
	var parent := get_editor_node(_tbt_node_parents[tbt_node])
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
	for node in _tbt_nodes.values():
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

	
func notify_tiles_inspector_added(p_tiles_inspector : Control) -> void:
	tiles_inspector = p_tiles_inspector
	_inject_tbt_reference(tiles_inspector, true)
	_call_subtree(self, TILES_INSPECTOR_ADDED_METHOD)
	tiles_inspector_added.emit()
	tiles_inspector.visibility_changed.connect(_on_tiles_inspector_visibility_changed)
	_setup_dynamic_containers()
	set_process_input(true)
	tiles_preview_expand_requested.emit()


func notify_tiles_inspector_removed() -> void:
	set_process_input(false)
	_call_subtree(self, TILES_INSPECTOR_REMOVED_METHOD)
	tiles_inspector_removed.emit()


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


func _on_tiles_inspector_visibility_changed() -> void:
	if !is_instance_valid(tiles_inspector) or !tiles_inspector.is_visible_in_tree():
		tiles_preview.hide()
		set_process_input(false)
	else:
		tiles_preview.show()
		set_process_input(true)


# while tiles inspector is visible, watch for mouse clicks and 
# collapse preview panel for clicks outside of this plugin
func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if not event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		return
	
	if is_dialog_popped_up():
		return
	
	var mouse_position = get_global_mouse_position()
	
	if tiles_inspector.get_parent_control().get_global_rect().has_point(mouse_position):
		if tiles_inspector.get_global_rect().has_point(mouse_position):
			if !tiles_preview.expanded:
				tiles_preview_expand_requested.emit()
		else:
			tiles_preview_collapse_requested.emit()
		return
	
	if !tiles_preview.expanded:
		return
	
	if tiles_preview.get_parent_control().get_global_rect().has_point(mouse_position):
		if !tiles_preview.get_mouse_input_rect().has_point(mouse_position):
			tiles_preview_collapse_requested.emit()












# ------------------------------------------------------------------------
#		INJECTIONS
# ------------------------------------------------------------------------

func _inject_tbt_reference(node : Node, include_parent := false) -> void:
	_set_subtree(node, TBT_PROPERTY_NAME, self, include_parent)
	_call_subtree(node, TBT_READY_METHOD, include_parent)


# ------------------------------------------------------------------------
#		NODE MANAGEMENT
# ------------------------------------------------------------------------

func _update_editor_references() -> Globals.Errors:
	_editor_nodes = {}
	
	var base_control := interface.get_base_control()
	_editor_nodes[EditorTreeNode.BASE_CONTROL] = base_control
	
	var tile_set_editor := _get_first_node_by_class(base_control, "TileSetEditor")
	if !tile_set_editor:
		return Globals.Errors.EDITOR_NODE_NOT_FOUND
	_editor_nodes[EditorTreeNode.TILE_SET_EDITOR] = tile_set_editor

	var atlas_source_editor := _get_first_node_by_class(tile_set_editor, "TileSetAtlasSourceEditor")
	if !atlas_source_editor:
		return Globals.Errors.EDITOR_NODE_NOT_FOUND
	_editor_nodes[EditorTreeNode.ATLAS_SOURCE_EDITOR] = atlas_source_editor
	
	var atlas_source_editor_vbox := _get_first_node_by_class(atlas_source_editor, "VBoxContainer")
	if !atlas_source_editor_vbox:
		return Globals.Errors.EDITOR_NODE_NOT_FOUND
	var selected_tiles_inspector := _get_first_node_by_class(atlas_source_editor_vbox, "EditorInspector")
	if !selected_tiles_inspector:
		return Globals.Errors.EDITOR_NODE_NOT_FOUND
	var selected_tiles_inspector_vbox := _get_first_node_by_class(selected_tiles_inspector, "VBoxContainer")
	if !selected_tiles_inspector_vbox:
		return Globals.Errors.EDITOR_NODE_NOT_FOUND
	_editor_nodes[EditorTreeNode.SELECTED_TILES_INSPECTOR_VBOX] = selected_tiles_inspector_vbox
	_setup_editor_signals(selected_tiles_inspector_vbox, "selected_tiles_inspector_vbox")


	var tile_atlas_view := _get_first_node_by_class(tile_set_editor, "TileAtlasView")
	if !tile_atlas_view:
		return Globals.Errors.EDITOR_NODE_NOT_FOUND
	_editor_nodes[EditorTreeNode.TILE_ATLAS_VIEW] = tile_atlas_view
	
	_atlas_source_proxy = _get_first_connected_object_by_class(atlas_source_editor, "TileSetAtlasSourceProxyObject")
	if !_atlas_source_proxy:
		return Globals.Errors.FAILED
	_atlas_source_proxy.property_list_changed.connect(_on_tile_set_source_changed)
	
	_atlas_tile_proxy = _get_first_connected_object_by_class(atlas_source_editor, "AtlasTileProxyObject")
	if !_atlas_tile_proxy:
		return Globals.Errors.FAILED
	_atlas_tile_proxy.property_list_changed.connect(_on_tiles_selected)

	return Globals.Errors.OK





# ------------------------------------------------------------------------
#		UPDATES
# ------------------------------------------------------------------------



func _update_tile_set_and_source() -> void:
	current_tile_set = _get_first_connected_object_by_class(get_editor_node(EditorTreeNode.TILE_SET_EDITOR), "TileSet")
	current_source = _get_first_connected_object_by_class(_atlas_source_proxy, "TileSetAtlasSource")








# ------------------------------------------------------------------------
#		HELPER FUNCTIONS
# ------------------------------------------------------------------------

func _get_children_recursive(node : Node) -> Array:
	return node.find_children("*", "", true, false)


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


func _call_subtree(parent : Node, method_name : String, include_parent := false) -> void:
	var nodes_to_call := _get_children_recursive(parent)
	if include_parent:
		nodes_to_call.append(parent)
		
	for node in nodes_to_call:
		if node.has_method(method_name):
			node.call(method_name)


func _set_subtree(parent : Node, property_name : String, value : Variant, include_parent := false) -> void:
	var nodes_to_set := _get_children_recursive(parent)
	if include_parent:
		nodes_to_set.append(parent)
		
	for node in nodes_to_set:
		node.set(property_name, value)


func _is_reference_valid(node) -> bool:
	if !is_instance_valid(node):
		return false
	if !node.is_inside_tree():
		output.warning("%s is not inside tree" % node)
		return false
	if node.is_queued_for_deletion():
		output.warning("%s is queued for deletion" % node)
		return false
	return true
#	return is_instance_valid(node) && node.is_inside_tree() && !node.is_queued_for_deletion()




# ------------------------------------------------------------------------
#		DEBUG SIGNALS
# ------------------------------------------------------------------------

func _setup_debug_signals() -> void:
	for signal_data in get_signal_list():
		if signal_data.args.size() == 0:
			connect(signal_data.name, _on_signal_emitted.bind(signal_data.name))
		else:
			connect(signal_data.name, _on_signal_emitted_with_arg.bind(signal_data.name))


# Use for debugging editor nodes
func _setup_editor_signals(node : Object, node_name : String) -> void:
	for signal_data in node.get_signal_list():
		if "mouse" in signal_data.name or "gui_input" in signal_data.name:
			continue
		var s : String = node_name + ": " + signal_data.name
		if signal_data.args.size() == 0:
			node.connect(signal_data.name, _on_signal_emitted.bind(s))
		else:
			node.connect(signal_data.name, _on_signal_emitted_with_arg.bind(s))


func _on_signal_emitted(signal_name := "") -> void:
	output.debug("[TBTPlugin] Signal emitted: %s" % signal_name)


func _on_signal_emitted_with_arg(arg = null, signal_name := "") -> void:
	output.debug("[TBTPlugin] Signal emitted: %s (%s)" % [signal_name, arg])



# ------------------------------------------------------------------------
#		SIGNALS
# ------------------------------------------------------------------------


func _on_tile_set_source_changed() -> void:
	_update_tile_set_and_source()


func _on_tiles_selected() -> void:
	print("_on_tiles_selected()")
	tiles_inspector.reparent(self)
	await get_tree().create_timer(5).timeout
	print("saved tiles_inspector? %s" % is_instance_valid(tiles_inspector))
	pass
