class_name CSVParser
extends Task

enum Type {
		STRING,
		INT,
		VECTOR2I,
		ARRAY_FLOAT,
		ARRAY_INT,
		BOOL}
static var parsers :Dictionary[Type, TypeParser] = {}
var table :String
var _reader :ArchiveReaderCSV
var _schema :Dictionary[String, Dictionary]


func _init(
		archive :ZIPReader,
		table_name :String,
		schema :Dictionary[String, Dictionary]
		) -> void:
	if parsers.is_empty():
		_init_parsers()
	table = table_name
	_schema = schema
	_reader = ArchiveReaderCSV.new(archive, table)
	_reader.done.connect(_on_reader_done)
	_reader.error.connect(_on_reader_error)


func begin() -> void:
	_reader.begin()


func get_rows_count() -> int:
	return _reader.get_rows_count()


func get_row(i: int) -> Dictionary[String, Variant]:
	var row := {}
	for key in _schema:
		var raw_value := _reader.get_value(i, key)
		var type := _schema[key].get("type", Type.STRING) as Type
		row[key] = parsers[type].parse(raw_value)
	return row


func _on_reader_done() -> void:
	for key in _schema:
		if ! _reader.has_column(key):
			if ! _schema[key].has("default"):
				errors.append(
						"Missing column '%s' in table '%s'"
						% [key, table]
				)
			continue
	if throw_stacked_errors():
		return
	for i in _reader.get_rows_count():
		for key in _schema:
			var raw_value := _reader.get_value(i, key)
			var type := _schema[key].get("type", Type.STRING) as Type
			var valid :bool = parsers[type].is_valid(raw_value, _schema[key])
			if ! valid:
				errors.append(
						"Invalid value for %s on row %s"
						% [key, i])
	if throw_stacked_errors():
		return
	done.emit()


func _on_reader_error(messages :PackedStringArray) -> void:
	throw_errors(messages)


func _init_parsers() -> void:
	parsers = {
		Type.STRING: CSV_String.new(),
		Type.INT: CSV_int.new(),
		Type.VECTOR2I: CSV_Vector2i.new(),
		Type.ARRAY_FLOAT: CSV_Array_float.new(),
		Type.ARRAY_INT: CSV_Array_int.new(),
		Type.BOOL: CSV_bool.new()
	}


@abstract class TypeParser:
	@abstract func parse(input :String)
	@abstract func stringify(input) -> String
	@abstract func is_valid(input :String, constraints := {}) -> bool


class CSV_String extends TypeParser:
	func parse(input :String) -> String:
		return input
	
	func stringify(input :String) -> String:
		return input
	
	func is_valid(input :String, constraints := {}) -> bool:
		if constraints.has("allowed_values") and ! input in constraints.allowed_values:
			return false
		return true


class CSV_int extends TypeParser:
	func parse(input :String) -> int:
		return input.to_int()
	
	func stringify(input :int) -> String:
		return String.num_int64(input)
	
	func is_valid(input :String, constraints := {}) -> bool:
		if ! input.is_valid_int():
			return false
		var value := parse(input)
		if constraints.get("non_negative", false) and value < 0:
			return false
		if constraints.has("min_value") and value < constraints.get("min_value"):
			return false
		if constraints.has("max_value") and value > constraints.get("max_value"):
			return false
		if ! value in constraints.get("allowed_values", [value]):
			return false
		return true


class CSV_Vector2i extends TypeParser:
	func parse(input :String) -> Vector2i:
		var parts := input.split(":")
		return Vector2i(parts[0].to_int(), parts[1].to_int())


	func stringify(input :Vector2i) -> String:
		return String.num_int64(input[0]) + ":" + String.num_int64(input[1])


	func is_valid(input :String, constraints := {}) -> bool:
		var parts := input.split(":")
		if ( parts.size() != 2
				or ! parts[0].is_valid_int()
				or ! parts[1].is_valid_int()
				):
			return false
		var value := parse(input)
		if constraints.get("non_negative", false) and (value.x < 0 or value.y < 0):
			return false
		return true


class CSV_Array_float extends TypeParser:
	func parse(input :String) -> PackedFloat32Array:
		var output := [] as PackedFloat32Array
		var parts := input.split(":")
		for part in parts:
			output.append(part.to_float())
		return output


	func stringify(input :PackedFloat32Array) -> String:
		var parts := [] as PackedStringArray
		for value in input:
			parts.append(String.num(value))
		return ":".join(parts)


	func is_valid(input :String, constraints := {}) -> bool:
		var parts := input.split(":")
		for part in parts:
			if ! part.is_valid_float():
				return false
			var value := part.to_float()
			if constraints.get("non_negative", false) and value < 0:
				return false
		return true


class CSV_Array_int extends TypeParser:
	func parse(input :String) -> PackedInt32Array:
		var output := [] as PackedInt32Array
		var parts := input.split (":")
		for part in parts:
			output.append(part.to_int())
		return output


	func stringify(input :PackedInt32Array) -> String:
		var parts := [] as PackedStringArray
		for value in input:
			parts.append(String.num(value))
		return ":".join(parts)


	func is_valid(input :String, constraints := {}) -> bool:
		var parts := input.split(":")
		for part in parts:
			if ! part.is_valid_int():
				return false
			var value := part.to_int()
			if constraints.get("non_negative", false) and value < 0:
				return false
		return true


class CSV_bool extends TypeParser:
	func parse(input :String) -> bool:
		return input == "t"
	
	
	func stringify(input :bool) -> String:
		return "t" if input else "f"
	
	
	func is_valid(input: String, constraints := {}) -> bool:
		return input in ["t", "f"]
