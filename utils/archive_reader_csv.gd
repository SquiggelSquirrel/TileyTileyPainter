class_name ArchiveReaderCSV
extends Task

var _data :Array[PackedStringArray]
var _keys :Array[StringName]
var _reader :ZIPReader
var _path :String


func _init(zip_reader :ZIPReader, file_path :String):
	_reader = zip_reader
	_path = file_path


func begin() -> void:
	if ! _reader.file_exists(_path):
		throw_error("File not found '%s'" % [_path])
		return
	var lines := _get_zipped_csv_lines(_reader, _path)
	_keys = lines[0]
	_data = lines.slice(1)
	_data.erase("")
	done.emit()


func has_column(key: StringName) -> bool:
	return _keys.has(key)


func get_value(index :int, key :StringName) -> String:
	var column := _keys.find(key)
	if column == -1:
		return ""
	return _data[index][column]


func get_rows_count() -> int:
	return _data.size()


static func _get_zipped_csv_lines(
		reader :ZIPReader,
		path :String
		) -> Array[PackedStringArray]:
	var buffer := reader.read_file(path)
	var file := FileAccess.create_temp(FileAccess.READ_WRITE)
	file.store_buffer(buffer)
	var lines := [] as Array[PackedStringArray]
	while file.get_position() < file.get_length():
		lines.append(file.get_csv_line())
	return lines
