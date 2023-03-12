@tool
extends "res://addons/tile_bit_tools/controls/tbt_plugin_control/popups/template_dialog.gd"


var dir : DirAccess
var save_path : String

func _setup_connections() -> void:
	tbt.edit_template_requested.connect(_on_edit_template_requested)



func _setup_edit_dialog(p_template_bit_data : TBTPlugin.TemplateBitData) -> void:
	template_bit_data = p_template_bit_data
	dir = tbt.template_manager.get_user_templates_dir()
	save_path = template_bit_data.resource_path
	
	show_dialog()



# overriden
func _setup_initial_values() -> void:
	name_edit.text = template_bit_data.template_name
	description_edit.text = template_bit_data.template_description
	tags_edit.text = _custom_tags_to_string()
	save_path_label.text = "Saving to: %s" % save_path


func _custom_tags_to_string() -> String:
	return ", ".join(template_bit_data._custom_tags)


# overriden
func _get_save_path(_valid_only := true) -> String:
	return save_path




func _on_edit_template_requested(p_template_bit_data : TBTPlugin.TemplateBitData) -> void:
	if p_template_bit_data != null:
		_setup_edit_dialog(p_template_bit_data)
	else:
		tbt.output.warning("Edit requested without bit data")
