class_name ConfirmQuitDialog
extends Window

signal discard_and_quit_confirmed
signal save_and_quit_confirmed


func _on_discard_and_quit_pressed() -> void:
	discard_and_quit_confirmed.emit()


func _on_save_and_quit_pressed() -> void:
	save_and_quit_confirmed.emit()


func _on_cancel_pressed() -> void:
	queue_free()
