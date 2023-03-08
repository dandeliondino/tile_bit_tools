@tool
extends Node


func notify_tiles_inspector_added(context : Node) -> void:
	for child in get_children():
		if child.has_method("_tiles_inspector_added"):
			child._tiles_inspector_added(context)


func notify_tiles_inspector_removed() -> void:
	for child in get_children():
		if child.has_method("_tiles_inspector_removed"):
			child._tiles_inspector_removed()











