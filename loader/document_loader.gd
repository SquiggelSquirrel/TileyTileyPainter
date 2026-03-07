class_name DocumentLoader
extends RefCounted

signal load_complete
signal error(String)
var path :String


func _init(load_path :String) -> void:
	path = load_path


func begin() -> void:
	var document := Document.new()
	
	var reader = ZIPReader.new()
	reader.open(path)
	
	var table := ArchiveReaderCSV.new(reader, "document.csv")
	if table.get_rows_count() != 1:
		error.emit("Failed to parse document.csv")
		return
	var version := table.get_value(0, &"save_version")
	if version != "0.0.0":
		error.emit("Unsupported version " + version)
		return
	
	load_complete.emit()
	
