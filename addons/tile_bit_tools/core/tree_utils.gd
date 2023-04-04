extends RefCounted


static func get_children_recursive(node : Node) -> Array:
	return node.find_children("*", "", true, false)


static func get_first_node_by_class(parent_node : Node, p_class_name : String) -> Node:
	var nodes := parent_node.find_children("*", p_class_name, true, false)
	if !nodes.size():
		return null
	return nodes[0]


static func get_first_connected_object_by_class(object : Object, p_class_name : String) -> Object:
	var objects := get_connected_objects_by_class(object, p_class_name)
	if !objects.size():
		return null
	return objects[0]


static func get_connected_objects_by_class(object : Object, p_class_name : String) -> Array:
	var objects := []
	for connection in object.get_incoming_connections():
		var connected_object = connection["signal"].get_object()
		if connected_object.is_class(p_class_name):
			objects.append(connected_object)
	return objects


static func call_subtree(parent : Node, method_name : String, include_parent := false) -> void:
	var nodes_to_call := get_children_recursive(parent)
	if include_parent:
		nodes_to_call.append(parent)
		
	for node in nodes_to_call:
		if node.has_method(method_name):
			node.call(method_name)


static func set_subtree(parent : Node, property_name : String, value : Variant, include_parent := false) -> void:
	var nodes_to_set := get_children_recursive(parent)
	if include_parent:
		nodes_to_set.append(parent)
		
	for node in nodes_to_set:
		node.set(property_name, value)
