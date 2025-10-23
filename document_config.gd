class_name DocumentConfig
extends Resource

enum TileTypes {
	SQUARE,
	HALF_OFFSET_SQUARE_HORIZONTAL,
	HALF_OFFSET_SQUARE_VERTICAL,
	HEXAGON_HORIZONTAL,
	HEXAGON_VERTICAL,
	ISOMETRIC}


@export var tile_type := TileTypes.SQUARE
@export var tile_size := Vector2i.ONE
@export var margin_top :int = 0
@export var margin_right :int = 0
@export var margin_bottom :int = 0
@export var margin_left :int = 0


func get_tile_outer_size() -> Vector2i:
	return tile_size + Vector2i(
			margin_left + margin_right,
			margin_top + margin_bottom)


func get_tile_inner_aab() -> Rect2i:
	return Rect2i(
			Vector2i(margin_left, margin_top),
			tile_size)
