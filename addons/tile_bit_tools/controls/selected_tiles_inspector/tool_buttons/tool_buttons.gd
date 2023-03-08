@tool
extends Control


const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
const Context := preload("res://addons/tile_bit_tools/core/context.gd")
const TilesManager := preload("res://addons/tile_bit_tools/controls/shared_nodes/tiles_manager.gd")
const InspectorManager := preload("res://addons/tile_bit_tools/controls/shared_nodes/inspector_manager.gd")

#var _print := preload("res://addons/tile_bit_tools/core/print.gd").new()

var fill_menu_items := {}


@onready var context : Context = get_tree().get_first_node_in_group(Globals.GROUP_CONTEXT)
@onready var tiles_manager : TilesManager = get_tree().get_first_node_in_group(Globals.GROUP_TILES_MANAGER)
@onready var inspector_manager : InspectorManager = get_tree().get_first_node_in_group(Globals.GROUP_INSPECTOR_MANAGER)

@onready var fill_button: MenuButton = %FillButton

func _ready() -> void:
	if !is_instance_valid(context):
		return
		
	_setup_fill_button()


func _setup_fill_button() -> void:
	fill_button.get_popup().id_pressed.connect(_on_fill_button_popup_id_pressed)
	fill_button.custom_minimum_size.x = fill_button.size.x + 22
	_populate_fill_menu()


func _populate_fill_menu() -> void:
	fill_button.get_popup().clear()
	
	var terrain_sets_count := context.tile_set.get_terrain_sets_count()
	if terrain_sets_count == 1:
		_populate_fill_menu_terrains(0)
	else:
		for i in range(terrain_sets_count):
			var id := fill_menu_items.size()
			fill_button.get_popup().add_item("Terrain Set [%s]" % i, id)
			fill_button.get_popup().set_item_disabled(id, true)
			fill_menu_items[id] = null
			_populate_fill_menu_terrains(i)


func _populate_fill_menu_terrains(terrain_set : int) -> void:
	for i in range(context.tile_set.get_terrains_count(terrain_set)):
		var terrain_name := context.tile_set.get_terrain_name(terrain_set, i)
		var terrain_color := context.tile_set.get_terrain_color(terrain_set, i)
		var icon := _get_icon(terrain_color)
		var id := fill_menu_items.size()
		fill_button.get_popup().add_icon_item(icon, terrain_name, id)
		fill_menu_items[id] = {"terrain_set": terrain_set, "terrain": i}
	

func _get_icon(p_color : Color) -> ImageTexture:
	var image := Image.create(16, 16, false, Image.FORMAT_RGB8)
	image.fill(p_color)
	return ImageTexture.create_from_image(image)



func _on_fill_button_popup_id_pressed(id : int) -> void:
	if fill_menu_items[id] == null:
		return
	var terrain_set : int = fill_menu_items[id].terrain_set
	var terrain : int = fill_menu_items[id].terrain
	tiles_manager.fill_terrain(terrain_set, terrain)
	

func _on_erase_button_pressed() -> void:
	tiles_manager.erase_terrains()



