@tool
extends EditorPlugin

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")

const PLUGIN_NAME := "tile_bit_tools"

const TBTPluginControl := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.tscn")

var texts := preload("res://addons/tile_bit_tools/core/texts.gd").new()
var output := preload("res://addons/tile_bit_tools/core/output.gd").new()

var plugin : EditorInspectorPlugin

var interface : EditorInterface
var tbt : TBTPlugin


func _enter_tree() -> void:
	output.debug("plugin.gd : _enter_tree()")
	output.info("Initializing TileBitTools v%s..." % Globals.VERSION)
	
	interface = get_editor_interface()
	
	_setup_project_settings()
	
	var result := await _add_tbt_plugin()
	if result != OK:
		output.user("Unable to initialize, disabling plugin")
		interface.set_plugin_enabled(PLUGIN_NAME, false)
		return
	
	
#	plugin = preload("inspector_plugin.gd").new()
#	add_inspector_plugin(plugin)
#	var result : Globals.Errors = plugin.setup(get_editor_interface())
#	if result != OK:
#		output.user("Unable to initialize, disabling plugin")
#		get_editor_interface().set_plugin_enabled(PLUGIN_NAME, false)
#		return
#	output.info("Initialization complete")
#	output.user(texts.WELCOME_MESSAGE)
#	output.user(texts.WELCOME_MESSAGE2)


func _clear() -> void:
	output.debug("plugin.gd : _clear()")
#	if plugin:
#		plugin.clean_up()


func _exit_tree() -> void:
	output.debug("plugin.gd : _exit_tree()")
	_remove_tbt_plugin()
	
#	output.info("Cleaning up...")
#	if plugin:
#		plugin.clean_up()
#	remove_inspector_plugin(plugin)



func _add_tbt_plugin() -> Globals.Errors:
	tbt = TBTPluginControl.instantiate()
	interface.get_base_control().add_child(tbt)
	if !tbt.ready_complete:
		await tbt.ready
	output.debug("TBTPluginControl ready in editor tree")
	var result := tbt.setup(interface)
	return result


func _remove_tbt_plugin() -> void:
	tbt.clean_up()
	tbt.queue_free()




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



