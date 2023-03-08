@tool
extends Node

signal preview_updated(preview_bit_data)
signal reset_requested

enum TerrainChanges {NONE, ERASE, FILL, TEMPLATE}

var terrain_changes_texts := {
	TerrainChanges.NONE: "",
	TerrainChanges.ERASE: "Erase terrain",
	TerrainChanges.FILL: "Fill terrain",
	TerrainChanges.TEMPLATE: "Apply terrain template",
}

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
const EditorBitData := preload("res://addons/tile_bit_tools/core/editor_bit_data.gd")
const TemplateBitData := preload("res://addons/tile_bit_tools/core/template_bit_data.gd")

const Context := preload("res://addons/tile_bit_tools/core/context.gd")

var _print := preload("res://addons/tile_bit_tools/core/print.gd").new()

var preview_bit_data : EditorBitData
var current_terrain_change := TerrainChanges.NONE

var context : Context

func _ready() -> void:
	reset_requested.connect(_on_reset_requested)


func _tiles_inspector_added(p_context : Context) -> void:
	context = p_context


func _tiles_inspector_removed() -> void:
	context = null


func clear_preview() -> void:
	preview_bit_data = null
	_emit_preview_updated()


func erase_terrains() -> void:
	preview_bit_data = _get_new_preview_data(context)
	preview_bit_data.clear_all_tile_terrains()
	current_terrain_change = TerrainChanges.ERASE
	_emit_preview_updated()


func fill_terrain(terrain_set : int, terrain_id : int) -> void:
	preview_bit_data = _get_new_preview_data(context)
	var terrain_mode : int = context.tile_set.get_terrain_set_mode(terrain_set)
	preview_bit_data.fill_all_tile_terrains(terrain_set, terrain_mode, terrain_id)
	current_terrain_change = TerrainChanges.FILL
	_emit_preview_updated()


func apply_template_terrains(template : TemplateBitData, terrain_set : int, terrain_mapping : Dictionary) -> void:
	if terrain_mapping.is_empty():
		preview_bit_data = null
		_emit_preview_updated()
		return
		
	preview_bit_data = _get_new_preview_data(context)
	var result := preview_bit_data.apply_template_bit_data(template, terrain_set, terrain_mapping)
	if result != OK:
		preview_bit_data = null
		current_terrain_change = TerrainChanges.NONE
		_print.error("Unable to apply template data", result)
		_emit_preview_updated()
		return
	
	current_terrain_change = TerrainChanges.TEMPLATE
	_emit_preview_updated()
	

## Applies the changes to TileData object
## including terrain_set, terrain and terrain peering bits
## There is no undo
func apply_bit_data() -> void:
	if !preview_bit_data:
		return
	
	_print.info(terrain_changes_texts[current_terrain_change])
	
	if current_terrain_change == TerrainChanges.ERASE:
		_print.user("Erasing terrain set assignments will cause error spam of Condition 'terrain_set < 0' is true. Data should save without corruption. Please ignore.")
		
	for coords in context.tiles.keys():
		var tile_data : TileData = context.tiles[coords]
		tile_data.terrain_set = preview_bit_data.terrain_set
		tile_data.terrain = preview_bit_data.get_tile_terrain(coords)
		for cell_neighbor in preview_bit_data.get_terrain_bits_list():
			var terrain := preview_bit_data.get_bit_terrain(coords, cell_neighbor)
			tile_data.set_terrain_peering_bit(cell_neighbor, terrain)



func _emit_preview_updated() -> void:
	preview_updated.emit(preview_bit_data)


func _get_new_preview_data(context : Context) -> EditorBitData:
	var copy : EditorBitData = context.bit_data.make_copy()
	return copy

func _on_reset_requested() -> void:
	_print.debug("reset requested from tiles manager")
	clear_preview()
