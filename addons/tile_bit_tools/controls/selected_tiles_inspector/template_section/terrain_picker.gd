@tool
extends Control

signal item_selected

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
const Context := preload("res://addons/tile_bit_tools/core/context.gd")


var EMPTY_ITEM_ID := -99

var terrain_label_text := "Terrain %s"

var index : int
var color : Color

var terrain_set : int :
	set(value):
		terrain_set = value
		_update_picker()

#var _print := TBTPrint.new()

@onready var context : Context = get_tree().get_first_node_in_group(Globals.GROUP_CONTEXT)

@onready var terrain_label: Label = %TerrainLabel
@onready var terrain_color_rect: ColorRect = %TerrainColorRect
@onready var terrain_option_button: OptionButton = %TerrainOptionButton


func setup(p_context : Context, p_index : int, p_color : Color) -> void:
	context = p_context
	index = p_index
	color = p_color
	_update_label()


func _ready() -> void:
	terrain_option_button.item_selected.connect(_emit_item_selected)


func get_selected_item_id() -> int:
	var id := terrain_option_button.get_selected_id()
	# id cannot be -1 in optionlist, so must be converted
	if id == EMPTY_ITEM_ID:
		return -1 
	return id


func _update_label() -> void:	
	terrain_label.text = terrain_label_text % index
	terrain_color_rect.color = color


func _update_picker() -> void:
#	print("_update_picker")
	if !context:
#		print("aborting")
		return
	
	terrain_option_button.clear()
	terrain_option_button.add_item("", EMPTY_ITEM_ID)
	
	if terrain_set == -1:
		return
	
	var terrains_count := context.tile_set.get_terrains_count(terrain_set)
	
	for i in range(terrains_count):
		var terrain_name := context.tile_set.get_terrain_name(terrain_set, i)
		var terrain_color := context.tile_set.get_terrain_color(terrain_set, i)
		var icon := _get_icon(terrain_color)
		terrain_option_button.add_icon_item(icon, terrain_name, i)


func _get_icon(p_color : Color) -> ImageTexture:
	var image := Image.create(16, 16, false, Image.FORMAT_RGB8)
	image.fill(p_color)
	return ImageTexture.create_from_image(image)


func _emit_item_selected(_index := -1) -> void:
	item_selected.emit()


func _on_terrain_set_changed(id : int) -> void:
#	print("_on_terrain_set_changed")
	terrain_set = id
	
