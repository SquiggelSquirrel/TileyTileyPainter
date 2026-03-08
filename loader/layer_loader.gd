class_name LayerLoader
extends Task

const MAIN_TABLE_FILENAME := "layers.csv"
const PAINT_TABLE_FILENAME := "paint_layers.csv"
const CLONE_TABLE_FILENAME := "clone_layers.csv"
static var main_schema := {
		"type": {
			"type": CSVParser.Type.STRING,
			"allowed_values": Layer.Type.keys()
		},
		"name": {
			"type": CSVParser.Type.STRING
		},
		"visible": {
			"type": CSVParser.Type.BOOL
		},
		"parent_layer_index": {
			"type": CSVParser.Type.INT,
			"min_value": 0
		}
	}
static var paint_layers_schema := {
		"layer_index": {
			"type": CSVParser.Type.INT,
			"min_value": 0
		},
		"file": {
			"type": CSVParser.Type.STRING
		},
		"offset": {
			"type": CSVParser.Type.VECTOR2I,
			"non_negative": true
		}
	}
static var clone_layers_schema := {
		"layer_index": {
			"type": CSVParser.Type.INT,
			"min_value": 0
		},
		"source_layer_index": {
			"type": CSVParser.Type.INT,
			"min_value": 0
		},
		"offset": {
			"type": CSVParser.Type.VECTOR2I
		}
	}
var archive :ZIPReader
var main_table_parser :CSVParser
var paint_table_parser :CSVParser
var clone_table_parser :CSVParser
var layers :Array[Layer]


func _init(zip_archive_reader :ZIPReader) -> void:
	archive = zip_archive_reader
	main_table_parser = CSVParser.new(archive, MAIN_TABLE_FILENAME, main_schema)
	main_table_parser.error.connect(_on_parser_error)
	main_table_parser.done.connect(_on_main_table_parser_done)


func begin() -> void:
	main_table_parser.begin()


func _on_main_table_load_complete() -> void:
	paint_table_parser = CSVParser.new(archive, PAINT_TABLE_FILENAME, paint_layers_schema)
	paint_table_parser.error.connect(_on_parser_error)
	paint_table_parser.done.connect(_on_paint_table_parser_done)
	paint_table_parser.begin()


func _on_paint_table_load_complete() -> void:
	clone_table_parser = CSVParser.new(archive, CLONE_TABLE_FILENAME, clone_layers_schema)
	clone_table_parser.error.connect(_on_parser_error)
	clone_table_parser.done.connect(_on_clone_table_parser_done)
	clone_table_parser.begin()


func _on_clone_table_load_complete() -> void:
	done.emit()


func _on_parser_error(messages :PackedStringArray) -> void:
	throw_errors(messages)


func _on_main_table_parser_done() -> void:
	layers = []
	for i in main_table_parser.get_rows_count():
		var row := main_table_parser.get_row(i)
		var type := row["type"] as String
		match type:
			"Paint":
				layers.append(PaintLayer.new())
			"Group":
				layers.append(GroupLayer.new())
			"Clone":
				layers.append(CloneLayer.new())
			_:
				error.emit(
						"Unsupported type %s in line %s of layers.csv"
						% [type, i])
				return
		
		for key in row:
			var value = row[key]
			if key == "type":
				continue
			elif key == "parent_layer_index":
				if (value >= i or ! layers[value] is GroupLayer):
					throw_error("Invalid parent index on line %s" % [i])
					return
				var parent_layer := (layers[value] as GroupLayer)
				parent_layer.child_layers.append(layers[i])
			else:
				layers[i].set(key, value)
	_on_main_table_load_complete()


func _on_paint_table_parser_done() -> void:
	for i in paint_table_parser.get_rows_count():
		var row := paint_table_parser.get_row(i)
		if (
				row.layer_index >= layers.size()
				or ! layers[row.layer_index] is PaintLayer
			):
			error.emit("Invalid layer index on line %s" % [i])
			return
		var layer := layers[row.layer_index] as PaintLayer
		
		for key in row:
			if key == "layer_index":
				continue
			var value = row[key]
			if key == "file":
				if ! archive.file_exists(value):
					throw_error("Missing file '%s' at line %s of paint layers" % [value, i])
					return
				var buffer := archive.read_file(value)
				layer.image = Image.new()
				var err := layer.image.load_png_from_buffer(buffer)
				if err != OK:
					throw_error("Error loading file '%s'" % [value])
					return
			else:
				layer.set(key, value)
	_on_paint_table_load_complete()


func _on_clone_table_parser_done() -> void:
	for i in clone_table_parser.get_rows_count():
		var row := clone_table_parser.get_row(i)
		if (
				row.layer_index >= layers.size()
				or ! layers[row.layer_index] is CloneLayer
			):
			error.emit("Invalid layer index on line %s" % [i])
			return
		var layer := layers[row.layer_index] as CloneLayer
		for key in row:
			if key == "layer_index":
				continue
			var value = row[key]
			layer.set(key, value)
	_on_clone_table_load_complete()
