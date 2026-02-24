class_name LayerLoader
extends RefCounted

signal load_complete
signal error(String)
const MAIN_SCHEMA := {
	&"type": CSVParser.Type.STRING,
	&"name": CSVParser.Type.STRING,
	&"visible": CSVParser.Type.BOOL,
	&"parent_layer_index": CSVParser.Type.INT
}
const PAINT_SCHEMA := {
	&"layer_index": CSV_Parser.Type.INT,
	&"file": CSVParser.Type.STRING,
	&"offset": CSVParser.Type.VECTOR2I
}
const CLONE_SCHEMA := {
	&"layer_index": CSV_Parser.Type.INT,
	&"source_layer_index": CSV_Parser.Type.INT,
	&"offset": CSVParser.Type.VECTOR2I
}
enum State {READY, LOADING, ERROR}
var state := State.READY
var archive :ZIPReader
var layers :Array[Layer]


func _init(zip_archive_reader :ZIPReader) -> void:
	archive = zip_archive_reader


func _on_error() -> void:
	state = State.ERROR


func begin() -> void:
	error.connect(_on_error, CONNECT_ONE_SHOT)
	state = State.LOADING
	parse_main_table()
	if state != State.ERROR:
		parse_paint_table()
	if state != State.ERROR:
		parse_clone_table()
	load_complete.emit()


func parse_main_table() -> void:
	var main_table := ArchiveReaderCSV.new(archive, "layers.csv")
	
	var errors := CSVParser.get_parsing_errors(main_table, MAIN_SCHEMA)
	if errors.size() > 0:
		error.emit("\n".join(errors))
		return
	
	layers = []
	for i in main_table.get_rows_count():
		var type := main_table.get_value(i, &"type")
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
		
		for key in MAIN_SCHEMA:
			if key == &"type":
				continue
			var text := main_table.get_value(i, key)
			var parser := CSVParser.parsers[MAIN_SCHEMA[key]]
			var value = parser.parse(text)
			if key == &"parent_layer_index":
				if (
						value < 0
						or value >= i
						or ! layers[value] is GroupLayer
					):
					error.emit("Invalid parent index on line %s" % [i])
					return
				var parent_layer := (layers[value] as GroupLayer)
				parent_layer.child_layers.append(layers[i])
			else:
				layers[i].set(key, value)


func parse_paint_table() -> void:
	var paint_table := ArchiveReaderCSV.new(archive, "paint_layers.csv")
	
	var errors := CSVParser.get_parsing_errors(paint_table, PAINT_SCHEMA)
	if errors.size() > 0:
		error.emit("\n".join(errors))
		return
	
	for i in paint_table.get_rows_count():
		var layer_index :int = CSVParser.parsers[CSVParser.Type.INT].parse(
				paint_table.get_value(i, &"layer_index"))
		if (
				layer_index < 0
				or layer_index >= layers.size()
				or ! layers[layer_index] is PaintLayer
			):
			error.emit("Invalid layer index on line %s" % [i])
			return
		
		for key in PAINT_SCHEMA:
			var text := paint_table.get_value(i, key)
			var parser := CSVParser.parsers[PAINT_SCHEMA[key]]
			var value = parser.parse(text)
			if key == &"file":
				# TODO
				pass
			else:
				layers[layer_index].set(key, value)


func parse_clone_table() -> void:
	var clone_table := ArchiveReaderCSV.new(archive, "clone_layers.csv")
	
	var errors := CSVParser.get_parsing_errors(clone_table, CLONE_SCHEMA)
	if errors.size() > 0:
		error.emit("\n".join(errors))
		return
	
	for i in clone_table.get_rows_count():
		var layer_index :int = CSVParser.parsers[CSVParser.Type.INT].parse(
				clone_table.get_value(i, &"layer_index"))
		if (
				layer_index < 0
				or layer_index >= layers.size()
				or ! layers[layer_index] is CloneLayer
			):
			error.emit("Invalid layer index on line %s" % [i])
			return
		
		for key in CLONE_SCHEMA:
			var text := clone_table.get_value(i, key)
			var parser := CSVParser.parsers[CLONE_SCHEMA[key]]
			var value = parser.parse(text)
			layers[layer_index].set(key, value)
