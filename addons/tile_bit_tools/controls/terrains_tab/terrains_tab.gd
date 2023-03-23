@tool
extends Control

const terrain_icon_size := Vector2i(64, 64) # TODO: make same size as sources
const NULL_TERRAIN_SET := -99
const NULL_TERRAIN := -1

const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")
const Icons := preload("res://addons/tile_bit_tools/core/icons.gd")
const TerrainTransitions := preload("res://addons/tile_bit_tools/core/terrain_transitions.gd")

var tbt : TBTPlugin
var icons : Icons
var texts := preload("res://addons/tile_bit_tools/core/texts.gd").new()
var tile_set : TileSet
var terrain_transitions : TerrainTransitions

var current_terrain_set := NULL_TERRAIN_SET
var current_terrain := NULL_TERRAIN

@onready var terrain_set_option_button: OptionButton = %TerrainSetOptionButton
@onready var terrains_list: ItemList = %TerrainsList
@onready var terrains_placeholder_label: Label = %TerrainsPlaceholderLabel

@onready var transitions_container: VBoxContainer = %TransitionsContainer
@onready var base_placeholder_label: Label = %BasePlaceholderLabel
@onready var transition_placeholder_label: Label = %TransitionPlaceholderLabel



# TODO: refresh on tileset change
func _ready() -> void:
	terrain_set_option_button.item_selected.connect(_on_terrain_set_selected)
	terrains_list.item_selected.connect(_on_terrain_selected)

func _tbt_ready() -> void:
	tbt.terrains_tab_show_requested.connect(_on_terrains_tab_show_requested)
	tbt.terrains_tab_hide_requested.connect(_on_terrains_tab_hide_requested)
	icons = Icons.new(tbt.base_control) 


# ------------------------------------------------------------------
# 		UPDATES
# ------------------------------------------------------------------


func _update() -> void:
	_update_terrain_transitions()
	_update_terrain_set_option_button()
	_update_terrains_list()
	

func _update_current_terrain_set() -> void:
	current_terrain_set = terrain_set_option_button.get_selected_id()
	_update_terrains_list()


func _update_current_terrain() -> void:
	var selected_terrains := terrains_list.get_selected_items()
	if selected_terrains.size() == 0:
		current_terrain = NULL_TERRAIN
	else:
		# multi-selection not allowed
		current_terrain = selected_terrains[0]
	_update_transitions_display()


# ------------------------------------------------------------------
# 		TERRAIN SETS OPTION BUTTON
# ------------------------------------------------------------------

func _update_terrain_set_option_button() -> void:
	terrain_set_option_button.clear()
	
	if tile_set.get_terrain_sets_count() == 0:
		terrain_set_option_button.add_item(texts.EMPTY_ITEM, NULL_TERRAIN_SET)
	
	for terrain_set_id in range(tile_set.get_terrain_sets_count()):
		var mode = tile_set.get_terrain_set_mode(terrain_set_id)
		var icon = icons.get_icon(icons.TERRAIN_MODE_ICONS[mode])
		var text := "[%s] %s" % [terrain_set_id, texts.TERRAIN_MODE_TEXTS[mode]]
		terrain_set_option_button.add_icon_item(icon, text, terrain_set_id)

	_update_current_terrain_set()



# ------------------------------------------------------------------
# 		TERRAINS LIST
# ------------------------------------------------------------------

func _update_terrains_list() -> void:
	terrains_list.clear()
	if current_terrain_set == NULL_TERRAIN_SET:
		print("current_terrain_set == NULL_TERRAIN_SET")
		_toggle_terrains_list(false)
		return
	
	var terrains_count := tile_set.get_terrains_count(current_terrain_set)
	if terrains_count == 0:
		print("terrains_count == 0")
		_toggle_terrains_list(false)
		return
	
	_toggle_terrains_list(true)
	
	for terrain_id in range(terrains_count):
		var text := tile_set.get_terrain_name(current_terrain_set, terrain_id)
		var color := tile_set.get_terrain_color(current_terrain_set, terrain_id)
		var icon := _get_terrain_icon(color)
		terrains_list.add_item(text, icon)



# ------------------------------------------------------------------
# 		TRANSITIONS
# ------------------------------------------------------------------


func _update_terrain_transitions() -> void:
	print("_update_terrain_transitions()")
	if !_tile_set_has_terrains():
		print("!_tile_set_has_terrains()")
		terrain_transitions = null
		return
		
	terrain_transitions = TerrainTransitions.new()
	terrain_transitions.setup_from_tile_set(tile_set)
	terrain_transitions.print_tiles()


func _update_transitions_display() -> void:
	pass



# ------------------------------------------------------------------
# 		HELPER FUNCTIONS
# ------------------------------------------------------------------

func _get_terrain_icon(color : Color) -> ImageTexture:
	var image := Image.create(terrain_icon_size.x, terrain_icon_size.y, false, Image.FORMAT_RGB8)
	image.fill(color)
	return ImageTexture.create_from_image(image)


func _tile_set_has_terrains() -> bool:
	if tile_set == null:
		return false
	if tile_set.get_terrain_sets_count() == 0:
		return false
	for terrain_set in range(tile_set.get_terrain_sets_count()):
		if tile_set.get_terrains_count(terrain_set) > 0:
			return true
	return false



func _toggle_terrains_list(value : bool) -> void:
	terrains_placeholder_label.visible = !value
	terrains_list.visible = value
	_toggle_transitions_container(value)


func _toggle_transitions_container(value : bool) -> void:
	transitions_container.visible = value



func _on_terrain_set_selected(_index : int) -> void:
	_update_current_terrain_set()


func _on_terrain_selected(_index : int) -> void:
	_update_current_terrain()


func _on_terrains_tab_show_requested(p_tile_set : TileSet) -> void:
	tile_set = p_tile_set
	_update()
	show()

func _on_terrains_tab_hide_requested() -> void:
	hide()
