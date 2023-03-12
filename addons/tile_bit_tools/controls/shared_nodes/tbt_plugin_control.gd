@tool
extends Control

const TBT_PROPERTY_NAME := "tbt"
const TBT_READY_METHOD := "_tbt_ready"
const TILES_INSPECTOR_ADDED_METHOD := "_tiles_inspector_added"
const TILES_INSPECTOR_REMOVED_METHOD := "_tiles_inspector_removed"

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
const Texts := preload("res://addons/tile_bit_tools/core/texts.gd")
const Icons := preload("res://addons/tile_bit_tools/core/icons.gd")
const Print := preload("res://addons/tile_bit_tools/core/print.gd")

const BitData := preload("res://addons/tile_bit_tools/core/bit_data.gd")
const EditorBitData := preload("res://addons/tile_bit_tools/core/editor_bit_data.gd")
const TemplateBitData := preload("res://addons/tile_bit_tools/core/template_bit_data.gd")

const InspectorManager := preload("res://addons/tile_bit_tools/controls/shared_nodes/inspector_manager.gd")
const TilesManager := preload("res://addons/tile_bit_tools/controls/shared_nodes/tiles_manager.gd")
const ThemeUpdater := preload("res://addons/tile_bit_tools/controls/shared_nodes/theme_updater.gd")
const Context := preload("res://addons/tile_bit_tools/core/context.gd")

var interface : EditorInterface
var base_control : Control

var inspector_manager : InspectorManager
var tiles_manager : TilesManager
var theme_updater : ThemeUpdater

var context : Context :
	get:
		if !_is_reference_valid(context):
			return null
		return context


var tiles_inspector : Control : 
	get:
		if !_is_reference_valid(tiles_inspector):
			return null
		return tiles_inspector


var tiles_preview : Control : 
	get:
		if !_is_reference_valid(tiles_preview):
			return null
		return tiles_preview


var output := Print.new()


func _ready() -> void:
	child_entered_tree.connect(_assign_child_by_class)
	_setup_shared_nodes()
	_inject_tbt_reference(self)


func setup(p_interface : EditorInterface, p_base_control : Control) -> void:
	interface = p_interface
	base_control = p_base_control


# TODO: call this after preview panel added
func notify_tiles_inspector_added(p_tiles_inspector : Node, p_tiles_preview : Node) -> void:
	tiles_inspector = p_tiles_inspector
	prints("tiles_inspector", tiles_inspector)
	
	_inject_tbt_reference(tiles_inspector, true)
	
	tiles_preview = p_tiles_preview
	prints("tiles_preview", tiles_preview)
	_inject_tbt_reference(tiles_preview, true)
	
	_call_subtree(self, TILES_INSPECTOR_ADDED_METHOD)
	

func notify_tiles_inspector_removed() -> void:
	_call_subtree(self, TILES_INSPECTOR_REMOVED_METHOD)


func _setup_shared_nodes() -> void:
	for child in get_children():
		_assign_child_by_class(child)


func _assign_child_by_class(child : Node) -> void:
	print(child.get_script())
	match child.get_script():
		InspectorManager:
			inspector_manager = child
		TilesManager:
			tiles_manager = child
		ThemeUpdater:
			theme_updater = child
		Context:
			context = child
		_:
			output.warning("Child of unknown class added to TBTPlugin: %s" % child)



func _inject_tbt_reference(node : Node, include_parent := false) -> void:
	_set_subtree(node, TBT_PROPERTY_NAME, self, include_parent)
	_call_subtree(node, TBT_READY_METHOD, include_parent)


func _set_subtree(parent : Node, property_name : String, value : Variant, include_parent := false) -> void:
	var nodes_to_set := _get_children_recursive(parent)
	if include_parent:
		nodes_to_set.append(parent)
		
	for node in nodes_to_set:
		node.set(property_name, value)


func _call_subtree(parent : Node, method_name : String, include_parent := false) -> void:
	var nodes_to_call := _get_children_recursive(parent)
	if include_parent:
		nodes_to_call.append(parent)
		
	for node in nodes_to_call:
		if node.has_method(method_name):
			node.call(method_name)


func _get_children_recursive(node : Node) -> Array:
	return node.find_children("*", "", true, false)


func _is_reference_valid(node : Node) -> bool:
	return is_instance_valid(node) && node.is_inside_tree() && !node.is_queued_for_deletion()
