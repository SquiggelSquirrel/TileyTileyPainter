@tool
extends Panel

const TILE_INNER_LINE_COLOR := Color.CRIMSON
const TILE_OUTER_LINE_COLOR := Color.CORNFLOWER_BLUE
@export var config :DocumentConfig


func _ready() -> void:
	config.changed.connect(queue_redraw)


func _draw() -> void:
	match config.tile_type:
		DocumentConfig.TileTypes.SQUARE:
			draw_tile_square()
		DocumentConfig.TileTypes.HALF_OFFSET_SQUARE_HORIZONTAL:
			pass
		DocumentConfig.TileTypes.HALF_OFFSET_SQUARE_VERTICAL:
			pass
		DocumentConfig.TileTypes.HEXAGON_HORIZONTAL:
			pass
		DocumentConfig.TileTypes.HEXAGON_VERTICAL:
			pass
		DocumentConfig.TileTypes.ISOMETRIC:
			pass


func draw_tile_square() -> void:
	var rescale := minf(
			size.x / config.tile_outer_aab.x,
			size.y / config.tile_outer_aab.y)
	var outer_aab := Rect2(
			Vector2.ZERO,
			config.tile_outer_aab * rescale)
	var inner_aab := Rect2(
			config.tile_inner_aab.position * rescale,
			config.tile_inner_aab.size * rescale)
	draw_rect(outer_aab, Color.WHITE)
	draw_rect(outer_aab, TILE_OUTER_LINE_COLOR, false, 1)
	draw_rect(inner_aab, TILE_INNER_LINE_COLOR, false, 1)
