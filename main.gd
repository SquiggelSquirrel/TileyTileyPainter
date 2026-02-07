class_name Main
extends Node

const confirm_quit_dialog := preload("res://confirm_quit_dialog.tscn")
const new_document_dialog := preload("res://new_document_dialog.tscn")
const file_open_dialog := preload("res://file_open_dialog.tscn")
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


func _on_file_open_requested() -> void:
	var dialog :FileDialog = file_open_dialog.instantiate()
	add_child(dialog)
	dialog.file_selected.connect(_on_file_open_confirmed)
	dialog.visible = true


func _on_file_open_confirmed(path: String) -> void:
	var reader = ZIPReader.new()
	reader.open(path)

	# Destination directory for the extracted files (this folder must exist before extraction).
	# Not all ZIP archives put everything in a single root folder,
	# which means several files/folders may be created in `root_dir` after extraction.
	var root_dir = DirAccess.open("user://")

	var files = reader.get_files()
	for file_path in files:
		# If the current entry is a directory.
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue

		# Write file contents, creating folders automatically when needed.
		# Not all ZIP archives are strictly ordered, so we need to do this in case
		# the file entry comes before the folder entry.
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)
