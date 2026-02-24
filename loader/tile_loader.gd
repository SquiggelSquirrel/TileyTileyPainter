class_name TileLoader
extends RefCounted

signal load_complete
signal error(String)
const SCHEMA := {
	&"position_in_tile": CSVParser.Type.VECTOR2I,
	&"size_in_tile": CSVParser.Type.VECTOR2I,
	&"origin": CSVParser.Type.VECTOR2I,
	&"animation_frame_durations": CSVParser.Type.ARRAY_FLOAT,
	&"atlas_index": CSVParser.Type.INT,
	&"grid_layout": CSVParser.Type.STRING
}
var archive :ZIPReader
var tiles :Array[Array]


func _init(zip_archive_reader :ZIPReader) -> void:
	archive = zip_archive_reader


func begin() -> void:
	var table := ArchiveReaderCSV.new(archive, "tiles.csv")
	
	var errors := CSVParser.get_parsing_errors(table, SCHEMA)
	if errors.size() > 0:
		error.emit("\n".join(errors))
		return
	
	tiles = []
	for i in table.get_rows_count():
		var tile = Tile.new()
		
		var atlas_index :int
		for key in SCHEMA:
			var text := table.get_value(i, key)
			var parser := CSVParser.parsers[SCHEMA[key]]
			if key == &"atlas_index":
				atlas_index = parser.parse(text)
			else:
				tile.set(key, parser.parse(text))
		
		if atlas_index > tiles.size():
			tiles.resize(atlas_index + 1)
			tiles[atlas_index] = [] as Array[Tile]
		tiles[atlas_index].append(tile)
	
	load_complete.emit()
