@tool
extends EditorPlugin

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")

const PLUGIN_NAME := "tile_bit_tools"

var texts := preload("res://addons/tile_bit_tools/core/texts.gd").new()
var _print := preload("res://addons/tile_bit_tools/core/print.gd").new()

var plugin : EditorInspectorPlugin


func _enter_tree() -> void:
	_print.debug("plugin.gd : _enter_tree()")
	_print.info("Initializing TileBitTools v%s..." % Globals.VERSION)
	
	_setup_project_settings()
	
	plugin = preload("inspector_plugin.gd").new()
	add_inspector_plugin(plugin)
	var result : Globals.Errors = plugin.setup(get_editor_interface())
	if result != OK:
		_print.user("Unable to initialize, disabling plugin")
		get_editor_interface().set_plugin_enabled(PLUGIN_NAME, false)
		return
	_print.info("Initialization complete")
	_print.user(texts.WELCOME_MESSAGE)
	_print.user(texts.WELCOME_MESSAGE2)


func _clear() -> void:
	_print.debug("plugin.gd : _clear()")
	if plugin:
		plugin.clean_up()


func _exit_tree() -> void:
	_print.debug("plugin.gd : _exit_tree()")
	_print.info("Cleaning up...")
	if plugin:
		plugin.clean_up()
	remove_inspector_plugin(plugin)




func _setup_project_settings() -> void:
	for key in Globals.Settings.keys():
		var setting : Dictionary = Globals.Settings[key]
		if !ProjectSettings.has_setting(setting.path):
			ProjectSettings.set(setting.path, setting.default)

		ProjectSettings.set_initial_value(setting.path, setting.default)
		ProjectSettings.add_property_info({
			"name": setting.path,
			"type": setting.type,
			"hint_string": setting.get("hint_string", null),
		})



