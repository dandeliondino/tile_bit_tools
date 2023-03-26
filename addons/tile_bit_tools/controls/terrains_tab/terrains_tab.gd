@tool
extends Control

const terrain_icon_size := Vector2i(64, 64) # TODO: make same size as sources
const tile_size := Vector2i(64, 64)
const NULL_TERRAIN_SET := -99
const NULL_TERRAIN := -1

const TILE_LOCATION_TOOLTIP_TEMPLATE := "Source: {source_id} ({source_name})\nAtlas coords: ({x},{y})\nProbability: {probability}"

const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")
const Icons := preload("res://addons/tile_bit_tools/core/icons.gd")
const TerrainTransitions := preload("res://addons/tile_bit_tools/core/terrain_transitions.gd")
const TransitionSet := preload("res://addons/tile_bit_tools/core/transition_set.gd")

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

@onready var base_placeholder_label: Label = %BasePlaceholderLabel
@onready var transition_placeholder_label: Label = %TransitionPlaceholderLabel

@onready var transitions_container: VBoxContainer = %TransitionsContainer
@onready var base_tiles_container: HFlowContainer = %BaseTilesContainer
@onready var transition_sets_container: Container = %TransitionSetsContainer


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
		current_terrain = selected_terrains[0]
	_update_transitions_panel()


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


func _update_transitions_panel() -> void:
	_clear_transitions_panel_tiles()
	if terrain_transitions == null:
		return
		
	_update_base_tiles_display()
	_update_transition_tiles_display()
#	tbt.theme_update_requested.emit(self)


func _update_transition_tiles_display() -> void:
	for transition_set in terrain_transitions.get_transition_sets(current_terrain_set, current_terrain):
		transition_set = transition_set as TransitionSet
		_add_transition_set_title(transition_set)
		
		var section_button := preload("res://addons/tile_bit_tools/controls/shared/inspector_section_button.tscn").instantiate()
		section_button.label_text = "Tiles"
		transition_sets_container.add_child(section_button)
		
		var transition_set_tiles_container := HFlowContainer.new()
		transition_sets_container.add_child(transition_set_tiles_container)
		
		for index in transition_set.get_used_indexes():
			_add_tile_index_control(index, transition_set.get_tile_locations_at_index(index), transition_set_tiles_container)
		
		section_button.expand_container = transition_set_tiles_container
		section_button.collapse()
#		tbt.theme_update_requested.emit(section_button)


func _add_transition_set_title(transition_set : TransitionSet) -> void:
	var label := Label.new()
	label.text = _get_transition_set_title(transition_set)
	transition_sets_container.add_child(label)


func _add_tile_index_control(index : int, tile_loc_list : Array, container : Control) -> void:
	var transition_tile := preload("res://addons/tile_bit_tools/controls/terrains_tab/transition_tile.tscn").instantiate()
	container.add_child(transition_tile)
	transition_tile.index_label.text = str(index)
	for tile_loc in tile_loc_list:
		var texture_rect := _get_tile_texture_rect(tile_loc)
		transition_tile.tiles_container.add_child(texture_rect)


func _get_transition_set_title(transition_set : TransitionSet) -> String:
	var TRANSITION_SET_TITLE_TEMPLATE := "{terrain} => {to_terrains}"
	var to_terrain_names := []
	for peering_terrain_id in transition_set.peering_terrain_ids:
		if peering_terrain_id != NULL_TERRAIN:
			to_terrain_names.append(tile_set.get_terrain_name(transition_set.terrain_set, peering_terrain_id))
		else:
			to_terrain_names.append("Void")
	var to_terrain_string := " and ".join(to_terrain_names)
	
	return TRANSITION_SET_TITLE_TEMPLATE.format({
		"terrain": tile_set.get_terrain_name(transition_set.terrain_set, transition_set.terrain_id),
		"to_terrains": to_terrain_string,
	})



func _update_base_tiles_display() -> void:
	var base_tiles : Array = terrain_transitions.get_base_tiles(current_terrain_set, current_terrain)
	if base_tiles.size() == 0:
		base_placeholder_label.show()
		return
	
	base_placeholder_label.hide()
	
	for tile_loc in base_tiles:
		var tile_texture_rect = _get_tile_texture_rect(tile_loc)
		base_tiles_container.add_child(tile_texture_rect)
		tile_texture_rect.tooltip_text = _get_tile_texture_rect_tooltip(tile_loc)



func _clear_transitions_panel_tiles() -> void:
	for child in base_tiles_container.get_children():
		child.queue_free()
	for child in transition_sets_container.get_children():
		child.queue_free()


func _get_tile_texture_rect(tile_loc) -> TextureRect:
	var source : TileSetAtlasSource = tile_set.get_source(tile_loc.source_id)
	var tile_rect := source.get_tile_texture_region(tile_loc.coords)
	var tile_image := source.texture.get_image().get_region(tile_rect)
	var tile_texture := ImageTexture.create_from_image(tile_image)
	var tile_texture_rect := TextureRect.new()
	tile_texture_rect.custom_minimum_size = tile_size
	tile_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	tile_texture_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	tile_texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR # TODO: not working; TODO: get from tilemap
	tile_texture_rect.texture = tile_texture
	return tile_texture_rect


func _get_tile_texture_rect_tooltip(tile_loc) -> String:
	var source = tile_set.get_source(tile_loc.source_id)

	return TILE_LOCATION_TOOLTIP_TEMPLATE.format({
		"source_id": tile_loc.source_id,
		"source_name": source.resource_name,
		"x": tile_loc.coords.x,
		"y": tile_loc.coords.y,
		"probability": source.get_tile_data(tile_loc.coords, 0).probability,
	})


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
