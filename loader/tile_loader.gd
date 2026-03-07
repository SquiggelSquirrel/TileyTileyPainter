class_name TileLoader
extends RefCounted

signal load_complete
signal error(String)
const SCHEMA := {
	"shape_id": {"type": CSVParser.Type.INT},
	"position_in_atlas": {"type": CSVParser.Type.VECTOR2I},
	"size_in_atlas": {"type": CSVParser.Type.VECTOR2I},
	"texture_origin": {"type": CSVParser.Type.VECTOR2I},
	"animation_frame_durations": {"type": CSVParser.Type.ARRAY_FLOAT},
	"animation_columns": {"type": CSVParser.Type.INT}
}
var archive :ZIPReader
var atlases :Array[Atlas]


func _init(zip_archive_reader :ZIPReader, parent_atlases :Array[Atlas]) -> void:
	archive = zip_archive_reader
	atlases = parent_atlases


func begin() -> void:
	var table := ArchiveReaderCSV.new(archive, "tiles.csv")
	
	var errors := CSVParser.get_parsing_errors(table, SCHEMA)
	if errors.size() > 0:
		error.emit("\n".join(errors))
		return
	
	for i in table.get_rows_count():
		var tile = Tile.new()
		
		var atlas_index :int
		var shape_id :int
		for key in SCHEMA:
			var text := table.get_value(i, key)
			var parser := CSVParser.parsers[SCHEMA[key].type]
			if key == &"atlas_index":
				atlas_index = parser.parse(text)
			elif key == &"shape_id":
				shape_id = parser.parse(text)
			else:
				tile.set(key, parser.parse(text))
		
		if atlas_index >= atlases.size():
			error.emit("Invalid atlas index at line %s" % [i])
			return
		atlases[atlas_index] = tile
		var shapes := atlases[atlas_index].tile_shapes_layout.tile_shapes
		if shape_id >= shapes.size():
			error.emit("Invalid atlas shape index at line %s" % [i])
			return
		tile.shape = shapes[shape_id]
	
	load_complete.emit()
