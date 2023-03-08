@tool
extends SplitContainer

const EMPTY_RECT := Rect2i(0,0,0,0)
const FRAME_0 := 0

const DEFAULT_TERRAIN_OPACITY := 0.75

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
const Context := preload("res://addons/tile_bit_tools/core/context.gd")
const TilesManager := preload("res://addons/tile_bit_tools/controls/shared_nodes/tiles_manager.gd")

const EditorBitData := preload("res://addons/tile_bit_tools/core/editor_bit_data.gd")

var preview_bit_data : EditorBitData

var tile_rects : Dictionary

var base_image : Image

var image_crop_rect : Rect2i

var initial_height : int



@onready var context : Context = get_tree().get_first_node_in_group(Globals.GROUP_CONTEXT)
@onready var tiles_manager : TilesManager = get_tree().get_first_node_in_group(Globals.GROUP_TILES_MANAGER)

@onready var collapsed_label: Label = %CollapsedLabel
@onready var preview_container: Container = %PreviewContainer
@onready var back_panel_container: PanelContainer = %BackPanelContainer

@onready var current_tiles_view: Container = %CurrentTilesView
@onready var preview_tiles_view: Container = %PreviewTilesView
@onready var terrain_opacity_slider: HSlider = %TerrainOpacitySlider

@onready var placeholder_label: RichTextLabel = %PlaceholderLabel

@onready var reset_button: Button = %ResetButton
@onready var apply_button: Button = %ApplyButton



func _ready() -> void:
	if !is_instance_valid(context):
		return
	
	context.tree_exiting.connect(queue_free)
	
	tiles_manager.preview_updated.connect(_on_preview_updated)
	apply_button.pressed.connect(tiles_manager.apply_bit_data)
	
	dragged.connect(_on_split_dragged)
	
	_setup_textures()
	
	await get_tree().process_frame
	initial_height = back_panel_container.size.y
	


func _setup_textures() -> void:
	_update_base_texture()
	_connect_opacity_slider()
	_update_current_terrain()
	_update_preview_terrain()


func _update_base_texture() -> void:
	_update_image_crop_rect()
	_create_base_image()
	var texture := ImageTexture.create_from_image(base_image)
	current_tiles_view.setup_base_tiles(texture, image_crop_rect.size)
	preview_tiles_view.setup_base_tiles(texture, image_crop_rect.size)


func _connect_opacity_slider() -> void:
	terrain_opacity_slider.value_changed.connect(current_tiles_view.set_terrain_overlay_opacity)
	terrain_opacity_slider.value_changed.connect(preview_tiles_view.set_terrain_overlay_opacity)
	terrain_opacity_slider.value = DEFAULT_TERRAIN_OPACITY
	terrain_opacity_slider.value_changed.emit(DEFAULT_TERRAIN_OPACITY)


func _update_current_terrain() -> void:
	current_tiles_view.set_bit_data(context.bit_data)
	


func _update_preview_terrain() -> void:
	if preview_bit_data:
		placeholder_label.hide()
		reset_button.show()
		preview_tiles_view.show()
		preview_tiles_view.set_bit_data(preview_bit_data)
		reset_button.disabled = false
		apply_button.disabled = false
		
	else:
		placeholder_label.show()
		reset_button.hide()
		preview_tiles_view.hide()
		preview_tiles_view.set_bit_data(null)
		reset_button.disabled = true
		apply_button.disabled = true
	
	


func _create_base_image() -> void:
	var texture := context.source.get_runtime_texture()
	base_image = texture.get_image().get_region(image_crop_rect)


func _update_image_crop_rect() -> void:
	image_crop_rect = EMPTY_RECT
	
	for coords in context.tiles.keys():
		var rect := context.source.get_runtime_tile_texture_region(coords, FRAME_0)
		if image_crop_rect == EMPTY_RECT:
			image_crop_rect = rect
		else:
			image_crop_rect = image_crop_rect.merge(rect)


func _on_preview_updated(bit_data : EditorBitData) -> void:
	print("_on_preview_updated")
	preview_bit_data = bit_data
	_update_preview_terrain()



func _on_split_dragged(_offset : int) -> void:
	# TODO: test with different resolutions
#	prints(back_panel_container.size.y, initial_height)
	if back_panel_container.size.y <= initial_height * 0.75:
		preview_container.hide()
		collapsed_label.show()
	else:
		preview_container.show()
		collapsed_label.hide()



func _on_reset_button_pressed() -> void:
	tiles_manager.reset_requested.emit()
