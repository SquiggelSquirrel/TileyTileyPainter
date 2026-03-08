class_name TileLoader
extends Task

const FILENAME := "files.csv"
var archive :ZIPReader
var parser :CSVParser
var atlases :Array[Atlas]


func _init(zip_archive_reader :ZIPReader, parent_atlases :Array[Atlas]) -> void:
	var schema := {
		"atlas_index": {
			"type": CSVParser.Type.INT,
			"min_value": 0
		},
		"shape_id": {
			"type": CSVParser.Type.INT,
			"min_value": 0
		},
		"position_in_atlas": {
			"type": CSVParser.Type.VECTOR2I,
			"non_negative": true
		},
		"size_in_atlas": {
			"type": CSVParser.Type.VECTOR2I,
			"non_negative": true
		},
		"texture_origin": {
			"type": CSVParser.Type.VECTOR2I
		},
		"animation_frame_durations": {
			"type": CSVParser.Type.ARRAY_FLOAT,
			"non_negative": true
		},
		"animation_columns": {
			"type": CSVParser.Type.INT,
			"non_negative": true
		}
	}
	schema.atlas_index.max_value = parent_atlases.size() - 1
	
	archive = zip_archive_reader
	atlases = parent_atlases
	parser = CSVParser.new(archive, FILENAME, schema)
	parser.error.connect(_on_parser_error)
	parser.done.connect(_on_parser_done)


func begin() -> void:
	parser.begin()


func _on_parser_error(messages :PackedStringArray) -> void:
	throw_errors(messages)


func _on_parser_done() -> void:
	for i in parser.get_rows_count():
		var row := parser.get_row(i)
		var tile = Tile.new()
		
		var atlas_index :int
		var shape_id :int
		for key in row:
			if key == "atlas_index":
				atlas_index = row[key]
			elif key == "shape_id":
				shape_id = row[key]
			else:
				tile.set(key, row[key])
		
		atlases[atlas_index] = tile
		var shapes := atlases[atlas_index].tile_shapes_layout.tile_shapes
		if shape_id >= shapes.size():
			error.emit("Invalid atlas shape index at line %s" % [i])
			return
		tile.shape = shapes[shape_id]
	
	done.emit()
