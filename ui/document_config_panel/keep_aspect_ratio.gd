extends Button

@export var input_1 :SpinBox
@export var input_2 :SpinBox
var _user_input := true
var _aspect_ratio :float


func _ready() -> void:
	if ! (input_1 is SpinBox and input_2 is SpinBox):
		return
	input_1.value_changed.connect(_on_value_changed.bind(true))
	input_2.value_changed.connect(_on_value_changed.bind(false))
	_update_aspect_ratio()


func _toggled(toggled_on: bool) -> void:
	if ! (input_1 is SpinBox and input_2 is SpinBox):
		return
	if ! toggled_on:
		return
	_update_aspect_ratio()


func _update_aspect_ratio() -> void:
	if input_2.value == 0.0:
		if input_1.value == 0.0:
			_aspect_ratio = 1.0
		else:
			_aspect_ratio = input_1.value / (input_2.value + 1.0)
	else:
		_aspect_ratio = input_1.value / input_2.value


func _on_value_changed(new_value: float, from_input_1: bool) -> void:
	if ! (input_1 is SpinBox and input_2 is SpinBox):
		return
	if ! ( _user_input and button_pressed ):
		return
	_user_input = false
	if from_input_1:
		var new_value_2 := new_value / _aspect_ratio
		if input_2.value != new_value_2:
			input_2.value = new_value_2
	else:
		var new_value_1 := _aspect_ratio * new_value
		if input_1.value != new_value_1:
			input_1.value = new_value_1
	_user_input = true
