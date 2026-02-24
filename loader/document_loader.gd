class_name DocumentLoader
extends RefCounted

signal load_complete(Document)
signal error(String)
var path :String


func _init(load_path :String) -> void:
	path = load_path


func begin() -> void:
	var document := DocumentConfig.new()
	
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
	#var parts := version.split(".")
	
	load_complete.emit(document)

	#var files = reader.get_files()
	#for file_path2 in files:
		## Skip directories
		#if file_path2.ends_with("/"):
			#continue
		#
		#var buffer = reader.read_file(file_path2)
		#
		#var image = Image.new()
		#image.load_png_from_buffer(buffer)
	
