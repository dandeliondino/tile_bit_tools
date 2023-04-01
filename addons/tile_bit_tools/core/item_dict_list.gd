extends Object

enum EmptyItemMode {
	NO_EMPTY_ITEM,
	ADD_EMPTY_ITEM,
	ADD_EMPTY_ITEM_IF_EMPTY,
}

const INDEX := "INDEX"
const ID := "ID"
const TEXT := "TEXT"
const ICON := "ICON"
const COLOR := "COLOR"
const MODE := "MODE"

const NULL_ID := -1
const NULL_TEXT := ""
const NULL_ICON := null

const Texts := preload("res://addons/tile_bit_tools/core/texts.gd")

var list := []

func _filter_list(item, filter_by : Dictionary) -> bool:
	for key in filter_by.keys():
		var value = filter_by[key]
		if !item.has(key):
			return false
		if item[key] != value:
			return false
	return true


func populate_control(control : Control, empty_item_mode : EmptyItemMode = EmptyItemMode.NO_EMPTY_ITEM, filter_by := {}) -> void:
	var filtered_list := list.filter(_filter_list.bind(filter_by))
	
	var add_empty_item := false
	if empty_item_mode == EmptyItemMode.ADD_EMPTY_ITEM:
		add_empty_item = true
	elif filtered_list.size() == 0 && empty_item_mode == EmptyItemMode.ADD_EMPTY_ITEM_IF_EMPTY:
		add_empty_item = true
	
	if add_empty_item:
		_add_item_to_control(control, Texts.EMPTY_ITEM, NULL_ICON, NULL_ID)
	
	for item in filtered_list:
		item = item as Dictionary
		var icon : Texture2D = item.get(ICON, NULL_ICON)
		var text : String = item.get(TEXT, NULL_TEXT)
		var id : int = item.get(ID, NULL_ID)
		
		_add_item_to_control(control, text, icon, id)


func _add_item_to_control(control : Control, text : String, icon : Texture2D, id : int) -> void:
	if control.get_class() == "OptionButton" or control.get_class() == "PopupMenu":
		_add_item_to_option_or_popup(control, text, icon, id)
	elif control.get_class() == "ItemList":
		_add_item_to_item_list(control, text, icon)


func _add_item_to_item_list(item_list : ItemList, text : String, icon : Texture2D) -> void:
	if icon != NULL_ICON && text == NULL_TEXT:
		item_list.add_icon_item(icon)
	else:
		item_list.add_item(text, icon)
		

func _add_item_to_option_or_popup(control : Control, text : String, icon : Texture2D, id : int) -> void:
	if icon == null:
		control.add_item(text, id)
	else:
		control.add_icon_item(icon, text, id)



