class_name Atlas
extends RefCounted

const MARGIN_TOP := 0
const MARGIN_RIGHT := 1
const MARGIN_BOTTOM := 2
const MARGIN_LEFT := 3

var origin :Vector2i
var tile_shapes_layout :TileShapesLayout
var tile_size :Vector2i
var tile_margins :PackedInt32Array
var tile_spacing :Vector2i
var tiles :Array[Tile]
