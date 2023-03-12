@tool
extends "res://addons/tile_bit_tools/controls/tbt_plugin_control/popups/template_dialog.gd"

var dir : DirAccess


func _setup_connections() -> void:
	name_edit.text_changed.connect(_update_save_path_label)
	tbt.save_template_requested.connect(_on_save_template_requested)


func _setup_save_dialog() -> void:
	dir = tbt.template_manager.get_user_templates_dir()
	template_bit_data = TBTPlugin.TemplateBitData.new()
	
	var result := template_bit_data.load_editor_bit_data(tbt.context.bit_data)
	if result != OK:
		tbt.output.error("Cannot create template from editor data", result) # TODO: error codes and popup message
			# TODO: message_box_requested not implemented
		tbt.message_box_requested.emit("Cannot create template from editor data (ERR %s)" % result)
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
	var path : String = tbt.template_manager.get_user_templates_path() + file_name
	
	if file_name == "":
		if valid_only:
			return ""
		else:
			return path
	
	if valid_only && !path.is_absolute_path():
		tbt.output.error("Unable to get valid save path: %s" % path)
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



func _on_save_template_requested() -> void:
	_setup_save_dialog()
