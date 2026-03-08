class_name DocumentLoader
extends Task

var _path :String
var document :Document
var _zip_reader :ZIPReader
var atlas_loader :AtlasLoader
var layer_loader :LayerLoader


func _init(load_path :String) -> void:
	_path = load_path


func begin() -> void:
	document = Document.new()
	document.save_path = _path
	
	_zip_reader = ZIPReader.new()
	_zip_reader.open(_path)
	
	var table := ArchiveReaderCSV.new(_zip_reader, "document.csv")
	if table.get_rows_count() != 1:
		error.emit("Failed to parse document.csv")
		return
	var version := table.get_value(0, &"save_version")
	if version != "0.0.0":
		error.emit("Unsupported version " + version)
		return
	document.save_version = "0.0.0"
	
	atlas_loader = AtlasLoader.new(_zip_reader)
	atlas_loader.error.connect(_on_loader_error)
	atlas_loader.done.connect(_on_atlas_loader_done)
	atlas_loader.begin()


func _on_loader_error(messages :PackedStringArray) -> void:
	throw_errors(messages)


func _on_atlas_loader_done() -> void:
	document.atlases = atlas_loader.atlases
	layer_loader = LayerLoader.new(_zip_reader)
	layer_loader.error.connect(_on_loader_error)
	layer_loader.done.connect(_on_layer_loader_done)


func _on_layer_loader_done() -> void:
	document.layers = layer_loader.layers
	document.has_unsaved_changes = false
	done.emit()
