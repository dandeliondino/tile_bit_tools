@tool
extends "res://addons/tile_bit_tools/controls/tbt_plugin_control/popups/template_dialog.gd"

const Context := preload("res://addons/tile_bit_tools/core/context.gd")

var dir : DirAccess


func _setup_connections() -> void:
	name_edit.text_changed.connect(_update_save_path_label)
	template_manager.save_template_requested.connect(_on_save_template_requested)


func _setup_save_dialog(context : Context) -> void:
	dir = template_manager.get_user_templates_dir()
	template_bit_data = TemplateBitData.new()
	
	var result := template_bit_data.load_editor_bit_data(context.bit_data)
	if result != OK:
		_print.error("Cannot create template from editor data", result) # TODO: error codes and popup message
		template_manager.message_box_requested.emit("Cannot create template from editor data (ERR %s)" % result)
		hide()
	
	show_dialog()



# overriden
func _setup_initial_values() -> void:
	name_edit.text = DEFAULT_TEMPLATE_NAME
	description_edit.text = DEFAULT_TEMPLATE_DESCRIPTION
	tags_edit.text = DEFAULT_TEMPLATE_TAGS
	_update_save_path_label()


func _update_save_path_label(_text := "") -> void:
	var path := _get_save_path(false)
	if path == "":
		save_path_label.text = "Unable to create valid save path"
		return
		
	save_path_label.text = "Saving to: %s" % path


# overriden
func _get_save_path(valid_only := true) -> String:
	var file_name := _get_file_name()
	var path : String = template_manager.get_user_templates_path() + file_name
	
	if file_name == "":
		if valid_only:
			return ""
		else:
			return path
	
	if valid_only && !path.is_absolute_path():
		_print.error("Unable to get valid save path: %s" % path)
		return ""
	
	return path


func _get_file_name() -> String:
	var template_name := name_edit.text
	if template_name == "":
		template_name = DEFAULT_TEMPLATE_NAME
	
	var s := template_name.to_lower().replace(" ", "_").validate_filename()
	var extension := ".tres"
	var file_name := s + extension
	
	var suffix := 0
	
	while dir.file_exists(file_name):
		suffix += 1
		file_name = s + str(suffix).pad_zeros(2) + extension
	
	return file_name



func _on_save_template_requested(context) -> void:
	if context != null:
		_setup_save_dialog(context)
	else:
		_print.warning("Save requested without context")
