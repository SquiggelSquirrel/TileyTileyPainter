extends Node

const confirm_quit_dialog := preload("res://confirm_quit_dialog.tscn")
const new_document_dialog := preload("res://new_document_dialog.tscn")
@export var document :DocumentConfig


func _ready() -> void:
	get_tree().set_auto_accept_quit(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_quit_requested()


func _on_quit_requested() -> void:
	if document != null and document.has_unsaved_changes:
		var dialog :ConfirmQuitDialog = confirm_quit_dialog.instantiate()
		add_child(dialog)
		dialog.save_and_quit_confirmed.connect(_on_save_and_quit_confirmed)
		dialog.discard_and_quit_confirmed.connect(discard_and_quit)
	else:
		discard_and_quit()


func _on_save_and_quit_confirmed() -> void:
	document.save()
	discard_and_quit()


func discard_and_quit() -> void:
	get_tree().quit()


func _on_file_new_requested() -> void:
	var dialog :NewDocumentDialog = new_document_dialog.instantiate()
	add_child(dialog)
	dialog.create_requested.connect(_set_document)


func _set_document(new_document :DocumentConfig) -> void:
	document = new_document
