extends Window


func _on_about_to_popup() -> void:
	$DocumentConfigPanel.document_config = DocumentConfig.new()
