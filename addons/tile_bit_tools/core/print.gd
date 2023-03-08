extends Object

# Colors
# salmon = error color
# webgray = info

# previously: palegreen

const Globals := preload("res://addons/tile_bit_tools/core/globals.gd")

func user(msg : String) -> void:
	if ProjectSettings.get_setting(Globals.Settings.output_show_user.path):
		msg = "[color=palegreen]TileBitTools:[/color] %s" % msg
		print_rich(msg)


func info(msg : String) -> void:
	if ProjectSettings.get_setting(Globals.Settings.output_show_info.path):
		msg = "[color=palegreen]TileBitTools:[/color] [color=webgray]%s[/color]" % msg
		print_rich(msg)


func debug(msg : String) -> void:
	if ProjectSettings.get_setting(Globals.Settings.output_show_debug.path):
		msg = "[color=palegreen]TileBitTools:[/color] [color=palegoldenrod]%s[/color]" % msg
		print_rich(msg)



func error(msg : String, err_code := -1) -> void:
	if ProjectSettings.get_setting(Globals.Settings.output_show_debug.path):
		msg = _format_error(msg, err_code)
		push_error(msg)


func warning(msg : String, err_code := -1) -> void:
	if ProjectSettings.get_setting(Globals.Settings.output_show_debug.path):
		msg = _format_error(msg, err_code)
		push_warning(msg)


func _format_error(msg : String, err_code := -1) -> String:
	msg = "TileBitTools: %s" % msg
	msg = msg + "(ERR %s)" % err_code if err_code != -1 else msg
	return msg
