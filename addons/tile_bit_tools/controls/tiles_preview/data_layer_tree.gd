@tool
extends Tree

enum Columns {
	NAME=0,
	VISIBILITY=1,
}

const VISIBILITY_BUTTON_ID := 0

const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")

var icon_hidden : Texture2D
var icon_visible : Texture2D

var tbt : TBTPlugin

var _root : TreeItem
var _property_root : TreeItem

var _layers_visibility := {}

var _items_by_layer := {}
var _layers_by_item := {}

func _tbt_ready() -> void:
	tbt.tiles_selected.connect(_on_tiles_selected)
	icon_hidden = tbt.icons.get_icon_by_editor_name("GuiVisibilityHidden")
	icon_visible = tbt.icons.get_icon_by_editor_name("GuiVisibilityVisible")
	
	_setup()


func _setup() -> void:
	columns = 2
	hide_root = true
	column_titles_visible = true
	set_column_title(Columns.NAME, "Data Layer")


func update_current_layers(selection_context : TBTPlugin.SelectionContext) -> void:
	clear()
	_layers_visibility.clear()

	_root = create_item()
	_property_root = _create_property_root()
	
	for i in selection_context.data_layers.size():
		_layers_visibility[i] = false
		var data_layer : TBTPlugin.DataLayer = selection_context.data_layers[i]
		var child := create_item(_property_root)
		child.set_text(Columns.NAME, data_layer.name)
		child.set_selectable(Columns.NAME, false)
#		child.set_icon(Columns.VISIBILITY, icon_hidden)
		child.add_button(Columns.VISIBILITY, icon_hidden, VISIBILITY_BUTTON_ID)
		_items_by_layer[i] = child
		_layers_by_item[child] = i


func _toggle_layer_visibility(item : TreeItem) -> void:
	item.set_button(Columns.VISIBILITY, VISIBILITY_BUTTON_ID, icon_visible)


func _create_property_root() -> TreeItem:
	var item := _root.create_child()
	item.set_text(0, "Properties")
	item.collapsed = true
	item.set_selectable(Columns.NAME, false)
	return item


func _on_tiles_selected(selection_context : TBTPlugin.SelectionContext) -> void:
	update_current_layers(selection_context)


func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	if column == Columns.VISIBILITY && id == VISIBILITY_BUTTON_ID:
		_toggle_layer_visibility(item)

