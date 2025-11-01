class_name DocumentConfig
extends Resource

enum TileTypes {
	SQUARE,
	HALF_OFFSET_SQUARE_HORIZONTAL,
	HALF_OFFSET_SQUARE_VERTICAL,
	HEXAGON_HORIZONTAL,
	HEXAGON_VERTICAL,
	ISOMETRIC}


var tile_type := TileTypes.SQUARE
var tile_size := Vector2i.ONE
var margin_top :int = 0
var margin_right :int = 0
var margin_bottom :int = 0
var margin_left :int = 0
var save_path :String

var has_unsaved_changes := true


func get_tile_outer_size() -> Vector2i:
	return tile_size + Vector2i(
			margin_left + margin_right,
			margin_top + margin_bottom)


func get_tile_inner_aab() -> Rect2i:
	return Rect2i(
			Vector2i(margin_left, margin_top),
			tile_size)


func save() -> void:
	print("Save not implemented yet")
	pass
