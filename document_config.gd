class_name DocumentConfig
extends Resource

enum TileTypes {
	SQUARE,
	HALF_OFFSET_SQUARE_HORIZONTAL,
	HALF_OFFSET_SQUARE_VERTICAL,
	HEXAGON_HORIZONTAL,
	HEXAGON_VERTICAL,
	ISOMETRIC}


@export var tile_type :TileTypes:
	set(value):
		if value != tile_type:
			tile_type = value
			emit_changed()
@export var tile_size: Vector2i:
	set(value):
		if value != tile_size:
			tile_size = value
			emit_changed()
@export var margin_top: int:
	set(value):
		if value != margin_top:
			margin_top = value
			emit_changed()
@export var margin_right: int:
	set(value):
		if value != margin_right:
			margin_right = value
			emit_changed()
@export var margin_bottom: int:
	set(value):
		if value != margin_bottom:
			margin_bottom = value
			emit_changed()
@export var margin_left: int:
	set(value):
		if value != margin_left:
			margin_left = value
			emit_changed()
