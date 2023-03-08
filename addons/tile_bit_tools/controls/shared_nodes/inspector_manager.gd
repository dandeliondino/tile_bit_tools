@tool
extends Node


signal templates_updated

signal save_template_requested(context)
signal edit_template_requested(template_bit_data)
signal message_box_requested(msg)

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")

const TemplateLoader := preload("res://addons/tile_bit_tools/core/template_loader.gd")
const TemplateBitData := preload("res://addons/tile_bit_tools/core/template_bit_data.gd")

const BitDataDrawNode := preload("res://addons/tile_bit_tools/controls/bit_data_draw/bit_data_draw_node.tscn")

const Context := preload("res://addons/tile_bit_tools/core/context.gd")

var _print := preload("res://addons/tile_bit_tools/core/print.gd").new()

var context : Context
var template_loader : TemplateLoader

var bit_data_draw_node


func _ready() -> void:
	_setup_bit_data_draw()
	_load_templates.call_deferred()

	for child in get_children():
		child.set("inspector_manager", self)


func _tiles_inspector_added(p_context : Context) -> void:
	_print.debug("inspector_manager: _tiles_inspector_added()")
	context = p_context


func _tiles_inspector_removed() -> void:
	_print.debug("inspector_manager: _tiles_inspector_removed()")
	context = null


func _setup_bit_data_draw() -> void:
	bit_data_draw_node = BitDataDrawNode.instantiate()
	add_child(bit_data_draw_node)
	

func _load_templates() -> void:
	bit_data_draw_node.tile_size = 16
	bit_data_draw_node.tile_spacing = 0
	template_loader = TemplateLoader.new(Globals.BUILTIN_TEMPLATES_PATH, get_user_templates_path())
	_create_template_textures.call_deferred()
	_print.info("%s templates loaded" % template_loader.get_templates().size())


func _create_template_textures() -> void:
	for template in template_loader.get_templates():
		template.preview_texture = await bit_data_draw_node.get_bit_texture(template)
#		_print.debug("Created preview texture for %s" % template.template_name)


func get_current_context() -> Context:
	if is_instance_valid(context):
		return context

	context = get_tree().get_first_node_in_group(Globals.GROUP_CONTEXT)
	
	if is_instance_valid(context):
		_print.debug("Context invalid, new context acquired")
		return context
	
	_print.error("Context invalid, unable to get context")
	return null


func update_templates() -> void:
	_load_templates()
	templates_updated.emit()


func get_user_templates_dir() -> DirAccess:
	var path := get_user_templates_path()
	var dir := DirAccess.open(path)
	if !dir:
		DirAccess.make_dir_recursive_absolute(path)
		dir = DirAccess.open(path)
		if !dir:
			_print.error("Unable to open user templates_to_tags directory")
			return dir
	return dir


func get_bit_data_draw() -> SubViewport:
	return bit_data_draw_node


func get_user_templates_path() -> String:
	return ProjectSettings.get_setting(Globals.Settings.user_templates_path.path)

