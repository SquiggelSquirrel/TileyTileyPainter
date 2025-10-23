extends Panel

const TILE_INNER_LINE_COLOR := Color.CRIMSON
const TILE_OUTER_LINE_COLOR := Color.CORNFLOWER_BLUE
@export var config :DocumentConfig:
	set(new_config):
		if config != null and config.changed.is_connected(queue_redraw):
			config.changed.disconnect(queue_redraw)
		config = new_config
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
	var image_size := config.get_tile_outer_size()
	var rescale := minf(
			size.x / image_size.x,
			size.y / image_size.y)
	var outer_aab := Rect2(
			Vector2.ZERO,
			image_size * rescale)
	var centering := (size - outer_aab.size) * 0.5
	outer_aab.position += centering
	var inner_aab := Rect2(config.get_tile_inner_aab())
	inner_aab.position = inner_aab.position * rescale + centering
	inner_aab.size = inner_aab.size * rescale
	draw_rect(outer_aab, Color.WHITE)
	var lines := [
			[Vector2(inner_aab.position.x, 0),
			Vector2(inner_aab.position.x, size.y)],
			[Vector2(inner_aab.end.x, 0),
			Vector2(inner_aab.end.x, size.y)],
			[Vector2(0, inner_aab.position.y),
			Vector2(size.x, inner_aab.position.y)],
			[Vector2(0, inner_aab.end.y),
			Vector2(size.x, inner_aab.end.y)]]
	for line in lines:
		draw_dashed_line(line[0], line[1], TILE_INNER_LINE_COLOR)
	draw_rect(outer_aab, TILE_OUTER_LINE_COLOR, false, 1)
	draw_rect(inner_aab, TILE_INNER_LINE_COLOR, false, 1)
