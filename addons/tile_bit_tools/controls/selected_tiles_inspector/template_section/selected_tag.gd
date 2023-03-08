@tool
extends PanelContainer

signal tag_removed

const TemplateTagData := preload("res://addons/tile_bit_tools/core/template_tag_data.gd")
const TemplateTag := TemplateTagData.TemplateTag

var tag : TemplateTag

@onready var icon_rect: TextureRect = %IconRect
@onready var label: Label = %Label
@onready var remove_button: Button = %RemoveButton

func _ready() -> void:
	remove_button.pressed.connect(_on_remove_button_pressed)


func setup(p_tag : TemplateTag) -> void:
	tag = p_tag
	
	label.text = tag.text
	
	if tag.icon:
		icon_rect.texture = tag.icon
	
	# TODO: implement in future?
#	if tag.color:
#		var stylebox : StyleBoxFlat = get("theme_override_styles/panel")
#		stylebox.bg_color = tag.color
	

func _on_remove_button_pressed() -> void:
	tag_removed.emit()
	queue_free()
