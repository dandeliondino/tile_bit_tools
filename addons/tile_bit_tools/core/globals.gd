extends Object

const VERSION := "0.2.0"

# ------------------------
# 	ERRORS
# ------------------------

enum Errors {
	OK = Error.OK,
	FAILED = Error.FAILED,
	MISSING_TILE_SET = 900,
	MISSING_SOURCE = 901,
	MISSING_TILES = 902,
	MISSING_BIT_DATA = 903,
	MULTIPLE_TERRAIN_SETS = 910,
	UNSUPPORTED_SHAPE = 911,
}







# ------------------------
# 	PATHS
# ------------------------

const BUILTIN_TEMPLATES_PATH := "res://addons/tile_bit_tools/templates/"



# ------------------------
# 	USER SETTINGS
# ------------------------

const PROJECT_SETTINGS_PATH := "addons/tile_bit_tools/"

const Settings := {
	"user_templates_path": {
		"path": PROJECT_SETTINGS_PATH + "paths/user_templates_path",
		"default": "user://addons/tile_bit_tools/templates/",
		"type": TYPE_STRING,
		"hint_string": PROPERTY_HINT_DIR,
	},
	"output_show_user": {
		"path": PROJECT_SETTINGS_PATH + "output/show_user_messages",
		"default": true,
		"type": TYPE_BOOL,
	},
	"output_show_info": {
		"path": PROJECT_SETTINGS_PATH + "output/show_info_messages",
		"default": false,
		"type": TYPE_BOOL,
	},
	"output_show_debug": {
		"path": PROJECT_SETTINGS_PATH + "output/show_debug_messages",
		"default": false,
		"type": TYPE_BOOL,
	},
	"colors_terrain_01": {
		"path": PROJECT_SETTINGS_PATH + "colors/template_terrain_1",
		"default": Color.RED,
		"type": TYPE_COLOR,
	},
	"colors_terrain_02": {
		"path": PROJECT_SETTINGS_PATH + "colors/template_terrain_2",
		"default": Color.BLUE,
		"type": TYPE_COLOR,
	},
	"colors_terrain_03": {
		"path": PROJECT_SETTINGS_PATH + "colors/template_terrain_3",
		"default": Color.YELLOW,
		"type": TYPE_COLOR,
	},
	"colors_terrain_04": {
		"path": PROJECT_SETTINGS_PATH + "colors/template_terrain_4",
		"default": Color.GREEN,
		"type": TYPE_COLOR,
	},
}


# ------------------------
# 	GROUPS
# ------------------------


const GROUP_DYNAMIC_CONTAINER := "TBT_DYNAMIC_CONTAINER"
