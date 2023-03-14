@tool
extends ItemList

const TBTPlugin := preload("res://addons/tile_bit_tools/controls/tbt_plugin_control/tbt_plugin_control.gd")

var template_bit_data : TBTPlugin.TemplateBitData

var tbt : TBTPlugin

var show_custom_tags := true

func update(template_bit_data : TBTPlugin.TemplateBitData) -> void:
	var item_list := []
	item_list.append({"text": "Tiles: %s" % template_bit_data.get_tile_count()})
	item_list.append({"text": "Terrains: %s" % template_bit_data.get_terrain_count()})

	var template_tag_data := preload("res://addons/tile_bit_tools/core/template_tag_data.gd").new()
	for tag in template_tag_data.tags.values():		
		if tag.get_test_result(template_bit_data):
			item_list.append({"text": tag.text, "icon": tag.icon})
	
	if show_custom_tags:
		for tag in template_bit_data.get_custom_tags():
			item_list.append({"text": tag})

	clear()
	for item in item_list:
		if item.has("icon"):
			add_item(item.text, item.icon, false)
		else:
			add_item(item.text, null, false)
