@tool
class_name DocumentConfig
extends Resource

enum TileTypes {
	SQUARE,
	HALF_OFFSET_SQUARE_HORIZONTAL,
	HALF_OFFSET_SQUARE_VERTICAL,
	HEXAGON_HORIZONTAL,
	HEXAGON_VERTICAL,
	ISOMETRIC}

@export var tile_outer_aab :Vector2i:
	set(value):
		if value != tile_outer_aab:
			tile_outer_aab = value
			_tile_inner_aab = _clamped_inner_aab(_tile_inner_aab)
			emit_changed()
			
@export var tile_inner_aab :Rect2i:
	set(value):
		value = _clamped_inner_aab(value)
		if value != _tile_inner_aab:
			_tile_inner_aab = value
			emit_changed()
	get:
		return _tile_inner_aab
var _tile_inner_aab :Rect2i

@export var tile_type :TileTypes:
	set(value):
		if value != tile_type:
			tile_type = value
			emit_changed()


func _clamped_inner_aab(aab_in: Rect2i) -> Rect2i:
	var clamped_position := aab_in.position.clamp(
			Vector2i.ZERO, tile_outer_aab - Vector2i.ONE)
	var aab_out := Rect2i(
			clamped_position,
			aab_in.size.clamp(
					Vector2i.ONE,
					tile_outer_aab - clamped_position))
	return aab_out
