class_name ArchiveReaderCSV
extends RefCounted


var _data :Array[PackedStringArray]
var _keys :Array[StringName]


func _init(reader :ZIPReader, path :String):
	var lines := _get_zipped_csv_lines(reader, path)
	_keys = lines[0]
	_data = lines.slice(1)
	_data.erase("")


func get_value(index :int, key :StringName) -> String:
	var column := _keys.find(key)
	if column == -1:
		return ""
	return _data[index][column]


func get_rows_count() -> int:
	return _data.size()


static func _get_zipped_csv_lines(
		reader :ZIPReader, path :String) -> Array[PackedStringArray]:
	if ! reader.file_exists(path):
		return []
	var buffer := reader.read_file(path)
	var file := FileAccess.create_temp(FileAccess.READ_WRITE)
	file.store_buffer(buffer)
	var lines := [] as Array[PackedStringArray]
	while file.get_position() < file.get_length():
		lines.append(file.get_csv_line())
	return lines
