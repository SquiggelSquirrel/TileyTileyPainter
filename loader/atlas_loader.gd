class_name AtlasLoader
extends RefCounted

signal load_complete
signal error(String)
const SCHEMA := {
		&"origin": CSVParser.Type.VECTOR2I,
		&"tile_size": CSVParser.Type.VECTOR2I,
		&"tile_spacing": CSVParser.Type.VECTOR2I,
		&"cell_size": CSVParser.Type.VECTOR2I}
var archive :ZIPReader
var atlases :Array[Atlas]
var _tile_loader :TileLoader

func _init(zip_archive_reader :ZIPReader) -> void:
	archive = zip_archive_reader


func begin() -> void:
	var table := ArchiveReaderCSV.new(archive, "atlases.csv")
	
	var errors := CSVParser.get_parsing_errors(table, SCHEMA)
	if errors.size() > 0:
		error.emit("\n".join(errors))
		return
	
	atlases = [] as Array[Atlas]
	for i in table.get_rows_count():
		var atlas = Atlas.new()
		for key in SCHEMA:
			var text := table.get_value(i, key)
			var parser := CSVParser.parsers[SCHEMA[key]]
			atlas.set(key, parser.parse(text))
		
		atlas.grid_layout = table.get_value(i, &"grid_layout")
		atlases.append(atlas)
	
	_tile_loader = TileLoader.new(archive)
	_tile_loader.load_complete.connect(_on_tile_loader_load_complete)
	_tile_loader.error.connect(_on_tile_loader_error)
	_tile_loader.begin()


func _on_tile_loader_load_complete() -> void:
	if _tile_loader.tiles.size() > atlases.size():
		error.emit("Tile atlas index exceeds number of atlases")
		return
	for i in atlases.size():
		atlases[i].tiles = _tile_loader.tiles[i]
	load_complete.emit()


func _on_tile_loader_error(msg :String) -> void:
	error.emit(msg)
