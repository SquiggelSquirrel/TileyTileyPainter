extends MenuButton

enum MenuIDs {NEW, OPEN, SAVE, SAVE_AS, EXIT}


func _ready() -> void:
	get_popup().id_pressed.connect(_on_id_pressed)


func _on_id_pressed(id :int) -> void:
	match id:
		MenuIDs.NEW:
			pass
		MenuIDs.OPEN:
			pass
		MenuIDs.SAVE:
			pass
		MenuIDs.SAVE_AS:
			pass
		MenuIDs.EXIT:
			pass
