extends Node

enum Type {STRING, INT, VECTOR2I, ARRAY_FLOAT, BOOL}
var parsers :Dictionary[Type, TypeParser] = {
	Type.STRING: CSV_String.new(),
	Type.INT: CSV_int.new(),
	Type.VECTOR2I: CSV_Vector2i.new(),
	Type.ARRAY_FLOAT: CSV_Array_float.new(),
	Type.BOOL: CSV_bool.new()
}


func get_parsing_errors(
		table :ArchiveReaderCSV,
		schema :Dictionary
		) -> PackedStringArray:
	var errors := [] as PackedStringArray
	for i in table.get_rows_count():
		for key in schema:
			var raw_value := table.get_value(i, key)
			var valid :bool = parsers[schema[key]].is_valid(raw_value)
			if ! valid:
				errors.append(
						"Invalid value for %s on row %s"
						% [key, i])
	return errors


@abstract class TypeParser:
	@abstract func parse(input :String)
	@abstract func stringify(input) -> String
	@abstract func is_valid(input :String) -> bool


class CSV_String extends TypeParser:
	func parse(input :String) -> String:
		return input
	
	func stringify(input :String) -> String:
		return input
	
	func is_valid(_input :String) -> bool:
		return true


class CSV_int extends TypeParser:
	func parse(input :String) -> int:
		return input.to_int()
	
	func stringify(input :int) -> String:
		return String.num_int64(input)
	
	func is_valid(input :String) -> bool:
		return (input == stringify(parse(input)))


class CSV_Vector2i extends TypeParser:
	func parse(input :String) -> Vector2i:
		var parts := input.split(":")
		return Vector2i(parts[0].to_int(), parts[1].to_int())


	func stringify(input :Vector2i) -> String:
		return String.num_int64(input[0]) + ":" + String.num_int64(input[1])


	func is_valid(input :String) -> bool:
		return (input == stringify(parse(input)))


class CSV_Array_float extends TypeParser:
	func parse(input :String) -> PackedFloat32Array:
		var output := [] as PackedFloat32Array
		var parts := input.split (":")
		for part in parts:
			output.append(part.to_float())
		return output


	func stringify(input :PackedFloat32Array) -> String:
		var parts := [] as PackedStringArray
		for value in input:
			parts.append(String.num(value))
		return ":".join(parts)


	func is_valid(input :String) -> bool:
		return (input == stringify(parse(input)))


class CSV_bool extends TypeParser:
	func parse(input :String) -> bool:
		return input == "t"
	
	
	func stringify(input :bool) -> String:
		return "t" if input else "f"
	
	
	func is_valid(input: String) -> bool:
		return input in ["t", "f"]
