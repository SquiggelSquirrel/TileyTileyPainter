@abstract class_name Task
extends RefCounted

signal done
signal progress
signal error(messages :PackedStringArray)

enum Status {
	READY,
	RUNNING,
	ERROR,
	COMPLETE
}
var status := Status.READY
var errors :PackedStringArray = []
var progress_ratio :float = 0.0


@abstract func begin() -> void


func append_errors(msg :String) -> void:
	errors.append(msg)
	status = Status.ERROR


func throw_error(msg :String = "") -> void:
	if msg != "":
		errors.append(msg)
	status = Status.ERROR
	error.emit(errors)


func throw_errors(messages :PackedStringArray) -> void:
	errors.append_array(messages)
	throw_error()


func throw_stacked_errors() -> bool:
	if errors.is_empty():
		return false
	throw_error()
	return true
