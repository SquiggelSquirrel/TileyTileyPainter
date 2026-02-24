extends MenuButton

signal new_requested
signal open_requested
signal save_requested
signal save_dialog_requested
signal quit_requested

enum MenuIDs {NEW, OPEN, SAVE, SAVE_AS, EXIT}


func _ready() -> void:
	get_popup().id_pressed.connect(_on_id_pressed)


func _on_id_pressed(id :int) -> void:
	match id:
		MenuIDs.NEW:
			new_requested.emit()
		MenuIDs.OPEN:
			open_requested.emit()
		MenuIDs.SAVE:
			save_requested.emit()
		MenuIDs.SAVE_AS:
			save_dialog_requested.emit()
		MenuIDs.EXIT:
			quit_requested.emit()
