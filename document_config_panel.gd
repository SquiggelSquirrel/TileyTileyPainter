extends PanelContainer

@export var config :DocumentConfig


func _ready() -> void:
	reset()
	%TileType.item_selected.connect(func(_index): write_values())
	for spin_box in [
			%Width, %Height,
			%MarginTop, %MarginRight, %MarginBottom, %MarginLeft]:
		spin_box.value_changed.connect(func(_value): write_values())


func reset() -> void:
	config = DocumentConfig.new()


func write_values() -> void:
	config.tile_type = %TileType.selected
	config.tile_size = Vector2i(floori(%Width.value), floori(%Height.value))
	config.margin_top = floori(%MarginTop.value)
	config.margin_bottom = floori(%MarginBottom.value)
	config.margin_left = floori(%MarginLeft.value)
	config.margin_right = floori(%MarginRight.value)
	config.emit_changed()
