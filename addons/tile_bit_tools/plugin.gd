@tool
extends EditorPlugin

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")
const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")

const PLUGIN_NAME := "tile_bit_tools"

const TBTPluginControl := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.tscn")
const InspectorPlugin := preload("res://addons/tile_bit_tools/inspector_plugin.gd")

var texts := preload("res://addons/tile_bit_tools/core/texts.gd").new()
var output := preload("res://addons/tile_bit_tools/core/output.gd").new()

var interface : EditorInterface
var tbt : TBTPlugin
var inspector_plugin : EditorInspectorPlugin


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
	output.debug("TBT setup complete")

	inspector_plugin = InspectorPlugin.new()
	add_inspector_plugin(inspector_plugin)
	inspector_plugin.setup(tbt)
	
	output.info("Initialization complete")
	output.user(texts.WELCOME_MESSAGE)
	output.user(texts.WELCOME_MESSAGE2)


func _clear() -> void:
	output.debug("plugin.gd : _clear()")
	pass


func _exit_tree() -> void:
	output.debug("plugin.gd : _exit_tree()")
	
	if is_instance_valid(tbt):
		tbt.clean_up()
		tbt.queue_free()
	
	if inspector_plugin:
		remove_inspector_plugin(inspector_plugin)


func _add_tbt_plugin() -> Globals.Errors:
	tbt = TBTPluginControl.instantiate()
	interface.get_base_control().add_child(tbt)
	if !tbt.ready_complete:
		await tbt.ready
	output.debug("TBTPluginControl ready in editor tree")
	var result := tbt.setup(interface)
	return result


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



