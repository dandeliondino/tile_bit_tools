@tool
extends PanelContainer


@onready var index_label: Label = %IndexLabel
@onready var bits_rect: TextureRect = %BitsRect
@onready var tiles_container: VBoxContainer = %TilesContainer

var index_label_text := ""


func _ready():
	index_label.text = index_label_text
