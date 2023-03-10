@tool
extends PanelContainer

const TemplateBitData := preload("res://addons/tile_bit_tools/core/template_bit_data.gd")

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
const InspectorManager := preload("res://addons/tile_bit_tools/controls/shared_nodes/inspector_manager.gd")

var info_label_text := "Type: {type}\nMode: {terrain_mode}\nTiles: {tile_count}\nTerrains: {terrain_count}"

var texts := preload("res://addons/tile_bit_tools/core/texts.gd").new()
var example_folder_path : String

var template_bit_data : TemplateBitData

@onready var inspector_manager : InspectorManager = get_tree().get_first_node_in_group(Globals.GROUP_INSPECTOR_MANAGER)

@onready var info_list: ItemList = %InfoList

@onready var template_rect: TextureRect = %TemplateRect

@onready var description_container: PanelContainer = %DescriptionContainer
@onready var expand_button: Button = %ExpandButton
@onready var description_label: RichTextLabel = %DescriptionLabel

@onready var example_button: Button = %ExampleButton
@onready var edit_button: Button = %EditButton
@onready var remove_button: Button = %RemoveButton






func _ready() -> void:
	hide()


func update(p_template_bit_data : TemplateBitData) -> void:
	template_bit_data = p_template_bit_data
	
	if !template_bit_data:
		hide()
		return
		
	show()
	
	if template_bit_data.template_description == "":
		description_container.hide()
	else:
		description_container.show()
	
	description_label.text = template_bit_data.template_description
	
	_update_info_list()
	
	
	if template_bit_data.built_in:
		edit_button.hide()
		remove_button.hide()
	else:
		edit_button.show()
		remove_button.show()
	
	if template_bit_data.example_folder_path != "" && template_bit_data.example_folder_path.is_absolute_path():
		example_folder_path = template_bit_data.example_folder_path
		example_button.show()
	else:
		example_folder_path = ""
		example_button.hide()

	template_rect.texture = template_bit_data.preview_texture



func _update_info_list() -> void:
	var item_list := []
	item_list.append({"text": "Tiles: %s" % template_bit_data.get_tile_count()})
	item_list.append({"text": "Terrains: %s" % template_bit_data.get_terrain_count()})

	var template_tag_data := preload("res://addons/tile_bit_tools/core/template_tag_data.gd").new()
	for tag in template_tag_data.tags.values():
		if tag.get_test_result(template_bit_data):
			item_list.append({"text": tag.text, "icon": tag.icon})
	
	for tag in template_bit_data.get_custom_tags():
		item_list.append({"text": tag})

	info_list.clear()
	for item in item_list:
		if item.has("icon"):
			info_list.add_item(item.text, item.icon, false)
		else:
			info_list.add_item(item.text, null, false)


func _toggle_description_expand_button(value : bool) -> void:
	if value:
		expand_button.icon = preload("res://addons/tile_bit_tools/controls/icons/arrow_down.svg")
		description_label.fit_content = true
	else:
		expand_button.icon = preload("res://addons/tile_bit_tools/controls/icons/arrow_right.svg")
		description_label.fit_content = false




func _open_example_folder() -> void:
	var path := ProjectSettings.globalize_path(example_folder_path)
	OS.shell_open(path)


# TODO: move to inspector_manager? make more generalized?
func _remove_template() -> void:
	var confirm_dialog := ConfirmationDialog.new()
	confirm_dialog.title = "Confirm Delete Template"
	confirm_dialog.dialog_text = "Really delete template '%s'?" % template_bit_data.template_name
	confirm_dialog.ok_button_text = "Delete (no undo)"
	confirm_dialog.confirmed.connect(_on_delete_confirmed)
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()


func _on_delete_confirmed() -> void:
	var path := template_bit_data.resource_path
	var dir := inspector_manager.get_user_templates_dir()
	dir.remove_absolute(path)
	inspector_manager.templates_update_requested.emit()


func _on_remove_button_pressed() -> void:
	_remove_template()
	

func _on_edit_button_pressed() -> void:
	inspector_manager.edit_template_requested.emit(template_bit_data)


func _on_example_button_pressed() -> void:
	_open_example_folder()


func _on_expand_button_toggled(button_pressed: bool) -> void:
	_toggle_description_expand_button(button_pressed)
