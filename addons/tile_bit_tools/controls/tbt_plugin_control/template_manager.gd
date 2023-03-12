@tool
extends Node



const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")

const TemplateLoader := preload("res://addons/tile_bit_tools/core/template_loader.gd")
const BitDataDrawNode := preload("res://addons/tile_bit_tools/controls/bit_data_draw/bit_data_draw_node.tscn")

var template_loader : TemplateLoader
var bit_data_draw_node

var tbt : TBTPlugin



func _tbt_ready() -> void:
	tbt.templates_update_requested.connect(update_templates)
	
	_setup_bit_data_draw()
	
	# call deferred so editor will not pause on activating plugin
	_load_templates.call_deferred() 


func _setup_bit_data_draw() -> void:
	bit_data_draw_node = BitDataDrawNode.instantiate()
	add_child(bit_data_draw_node)
	

func _load_templates() -> void:
	bit_data_draw_node.tile_size = 16
	bit_data_draw_node.tile_spacing = 0
	template_loader = TemplateLoader.new(tbt.Globals.BUILTIN_TEMPLATES_PATH, get_user_templates_path())
	_create_template_textures.call_deferred()
	tbt.output.info("%s templates loaded" % template_loader.get_templates().size())


func _create_template_textures() -> void:
	for template in template_loader.get_templates():
		template.preview_texture = await bit_data_draw_node.get_bit_texture(template)
#		tbt.output.debug("Created preview texture for %s" % template.template_name)


# TODO: remove
func get_current_context() -> TBTPlugin.Context:
	if tbt:
		return tbt.context
	return null


func update_templates() -> void:
	_load_templates()
	tbt.templates_updated.emit()


func get_user_templates_dir() -> DirAccess:
	var path := get_user_templates_path()
	var dir := DirAccess.open(path)
	if !dir:
		DirAccess.make_dir_recursive_absolute(path)
		dir = DirAccess.open(path)
		if !dir:
			tbt.output.error("Unable to open user templates_to_tags directory")
			return dir
	return dir


func get_bit_data_draw() -> SubViewport:
	return bit_data_draw_node


func get_user_templates_path() -> String:
	return ProjectSettings.get_setting(tbt.Globals.Settings.user_templates_path.path)

