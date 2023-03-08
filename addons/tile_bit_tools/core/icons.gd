extends Object


const TERRAIN_MODE_ICONS := {
	TileSet.TerrainMode.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES : ["TerrainMatchCornersAndSides", "EditorIcons"],
	TileSet.TerrainMode.TERRAIN_MODE_MATCH_CORNERS : ["TerrainMatchCorners", "EditorIcons"],
	TileSet.TerrainMode.TERRAIN_MODE_MATCH_SIDES : ["TerrainMatchSides", "EditorIcons"],
}

var control : Control

func _init(p_control : Control) -> void:
	control = p_control


func get_icon(icon_data : Array) -> Texture2D:
	return control.get_theme_icon(icon_data[0], icon_data[1])
