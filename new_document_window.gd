extends Window
signal create_requested(DocumentConfig)


func _ready() -> void:
	%DocumentConfigPanel.config = DocumentConfig.new()
	_close()


func _on_close_requested() -> void:
	_close()


func _on_cancel_pressed() -> void:
	_close()


func _on_create_pressed() -> void:
	create_requested.emit(%DocumentConfigPanel.config)


func _close() -> void:
	visible = false
	queue_free()
