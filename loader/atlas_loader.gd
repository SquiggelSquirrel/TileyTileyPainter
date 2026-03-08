class_name AtlasLoader
extends Task

const FILENAME := "atlases.csv"
static var schema := {}
var archive :ZIPReader
var parser :CSVParser
var atlases :Array[Atlas]
var _tile_loader :TileLoader


func _init(zip_archive_reader :ZIPReader) -> void:
	if schema.is_empty():
		_init_schema()
	archive = zip_archive_reader
	parser = CSVParser.new(archive, FILENAME, schema)
	parser.error.connect(_on_parser_error)
	parser.done.connect(_on_parser_ready)


func begin() -> void:
	parser.begin()


func _init_schema() -> void:
	schema = {
		"origin": {
			"type": CSVParser.Type.VECTOR2I
		},
		"tile_shapes_layout": {
			"type": CSVParser.Type.STRING
		},
		"tile_size": {
			"type": CSVParser.Type.VECTOR2I,
			"non_negative": true
		},
		"tile_margins": {
			"type": CSVParser.Type.ARRAY_INT,
			"non_negative": true
		},
		"tile_spacing": {
			"type": CSVParser.Type.VECTOR2I,
			"non_negative": true
		}
	}
	schema.tile_shapes_layout.set(
			"allowed_values",
			Application.tile_shapes_layouts.keys())


func _on_parser_error() -> void:
	throw_errors(parser.errors)


func _on_parser_ready() -> void:
	atlases = [] as Array[Atlas]
	for i in parser.get_rows_count():
		var atlas = Atlas.new()
		var row := parser.get_row(i)
		for key in row:
			if key == &"tile_shapes_layout":
				atlas.tile_shapes_layout = (
						Application.tile_shapes_layouts[row[key]])
			else:
				atlas.set(key, row[key])
		atlases.append(atlas)
	
	_tile_loader = TileLoader.new(archive, atlases)
	_tile_loader.done.connect(_on_tile_loader_done)
	_tile_loader.error.connect(_on_tile_loader_error)
	_tile_loader.begin()


func _on_tile_loader_error(msg :String) -> void:
	error.emit(msg)


func _on_tile_loader_done() -> void:
	if _tile_loader.tiles.size() > atlases.size():
		error.emit("Tile atlas index exceeds number of atlases")
		return
	for i in atlases.size():
		atlases[i].tiles = _tile_loader.tiles[i]
	done.emit()
