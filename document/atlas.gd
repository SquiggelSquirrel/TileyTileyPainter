class_name Atlas
extends RefCounted

var origin :Vector2i
var tile_size :Vector2i
var tile_spacing :Vector2i
var cell_size: Vector2i
# TODO: replace with reference to GridLayout object
var grid_layout :StringName
var tiles :Array[Tile]
