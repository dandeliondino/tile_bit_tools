extends Object

const SEPARATOR := 0

const TemplateBitData := preload("res://addons/tile_bit_tools/core/template_bit_data.gd")

enum Tags {
	BUILT_IN,
	USER,
	ONE_OR_TWO_TERRAINS,
	THREE_PLUS_TERRAINS,
	MATCH_CORNERS_AND_SIDES,
	MATCH_CORNERS,
	MATCH_SIDES,
}


class TemplateTag:
	var test_func : Callable
	var text : String
	var color : Color
	var icon : Texture2D
	var custom_tag := false
	
	var id : int

	func _init(p_text : String, p_test_func = null, p_icon = null, p_color = null):
		text = p_text
		if p_test_func:
			test_func = p_test_func
		if p_icon:
			icon = p_icon
		if p_color:
			color = p_color


	func get_template_has_tag(bit_data : TemplateBitData) -> bool:
		if test_func:
			return test_func.call(bit_data)
		else:
			return text in bit_data._custom_tags
	
	func get_test_result(bit_data : TemplateBitData) -> bool:
		return test_func.call(bit_data)

	func has_test() -> bool:
		if test_func:
			return true
		return false



var tags := {
	Tags.BUILT_IN: TemplateTag.new(
		"Type: Built-In",
		func(bit_data: TemplateBitData): 
			return bit_data.built_in,
		null,
		null,
	),
	Tags.USER: TemplateTag.new(
		"Type: User",
		func(bit_data: TemplateBitData): 
			return !bit_data.built_in,
		null,
		Color.YELLOW,
	),
#	Tags.ONE_OR_TWO_TERRAINS: TemplateTag.new(
#		"Terrains: 1-2",
#		func(bit_data: TemplateBitData): 
#			return bit_data.template_terrain_count <= 2,
#		null,
#		null,
#	),
#	Tags.THREE_PLUS_TERRAINS: TemplateTag.new(
#		"Terrains: 3+",
#		func(bit_data: TemplateBitData): 
#			return bit_data.template_terrain_count >= 3,
#		null,
#		null,
#	),
	Tags.MATCH_CORNERS_AND_SIDES: TemplateTag.new(
		"Mode: Corners and Sides",
		func(bit_data: TemplateBitData):
			return bit_data.terrain_mode == TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES,
		preload("res://addons/tile_bit_tools/controls/icons/terrainmatchcornersandsides.svg"),
		null,
	),
	Tags.MATCH_CORNERS: TemplateTag.new(
		"Mode: Corners",
		func(bit_data: TemplateBitData):
			return bit_data.terrain_mode == TileSet.TERRAIN_MODE_MATCH_CORNERS,
		preload("res://addons/tile_bit_tools/controls/icons/terrainmatchcorners.svg"),
		null,
	),
	Tags.MATCH_SIDES: TemplateTag.new(
		"Mode: Sides",
		func(bit_data: TemplateBitData):
			return bit_data.terrain_mode == TileSet.TERRAIN_MODE_MATCH_SIDES,
		preload("res://addons/tile_bit_tools/controls/icons/terrainmatchsides.svg"),
		null,
	),
}

var tag_display := [
	Tags.BUILT_IN,
	Tags.USER,
	Tags.MATCH_CORNERS_AND_SIDES,
	Tags.MATCH_CORNERS,
	Tags.MATCH_SIDES,
#	Tags.ONE_OR_TWO_TERRAINS,
#	Tags.THREE_PLUS_TERRAINS,
]
