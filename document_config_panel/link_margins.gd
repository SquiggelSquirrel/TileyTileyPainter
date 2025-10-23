extends Button


@export var button1 :Button
@export var button2 :Button


func _ready() -> void:
	if ! (button1 is Button and button2 is Button):
		return
	button1.toggled.connect(_on_button_changed)
	button2.toggled.connect(_on_button_changed)


func _on_button_changed(toggled_on: bool) -> void:
	if ! toggled_on:
		set_pressed_no_signal(false)


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		button1.set_pressed_no_signal(true)
		button2.set_pressed_no_signal(true)
