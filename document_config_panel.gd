extends PanelContainer

@export var config :DocumentConfig


func reset() -> void:
	config = DocumentConfig.new()


func write_values() -> void:
	config.tile_type = %TileType.selected
	config.tile_outer_aab.x = %ImageWidth.value
	config.tile_outer_aab.y = %ImageHeight.value
	config.tile_inner_aab.position.x = %TilePositionX.value
	config.tile_inner_aab.position.y = %TilePositionY.value
	config.tile_inner_aab.size.x = %TileWidth.value
	config.tile_inner_aab.size.y = %TileHeight.value
