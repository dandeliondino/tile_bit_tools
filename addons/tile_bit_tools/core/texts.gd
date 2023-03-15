extends Object

const BitData := preload("res://addons/tile_bit_tools/core/bit_data.gd")

const TERRAIN_MODE_TEXTS := {
	TileSet.TerrainMode.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES : "Corners and Sides",
	TileSet.TerrainMode.TERRAIN_MODE_MATCH_CORNERS : "Corners",
	TileSet.TerrainMode.TERRAIN_MODE_MATCH_SIDES : "Sides",
}

const TERRAIN_BIT_TEXTS := {
	BitData.TerrainBits.TOP_LEFT_CORNER: "Top Left Corner",
	BitData.TerrainBits.TOP_SIDE: "Top Side",
	BitData.TerrainBits.TOP_RIGHT_CORNER: "Top Right Corner",
	BitData.TerrainBits.RIGHT_SIDE: "Right Side",
	BitData.TerrainBits.BOTTOM_RIGHT_CORNER: "Bottom Right Corner",
	BitData.TerrainBits.BOTTOM_SIDE: "Bottom Side",
	BitData.TerrainBits.BOTTOM_LEFT_CORNER: "Bottom Left Corner",
	BitData.TerrainBits.LEFT_SIDE: "Left Side",
	BitData.TerrainBits.CENTER: "Terrain ID (Center Bit)",
}

const EMPTY_ITEM := "<empty>"

const WELCOME_MESSAGE := "Welcome to TileBitTools. Please report bugs or suggestions to github.com/dandeliondino/tile_bit_tools. To change which messages you see here, go to Project Settings -> General -> Addons -> Tile Bit Tools (make sure 'Advanced' is enabled)"
const WELCOME_MESSAGE2 := "Note: Please back up your project before applying any changes."











