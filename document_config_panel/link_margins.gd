extends Button


@export var button1 :Button
@export var button2 :Button
@export var inputs :Array[SpinBox]
var _offsets :Array[int] = [0,0,0,0]


func _ready() -> void:
	if ! (button1 is Button and button2 is Button):
		return
	button1.toggled.connect(_on_button_changed)
	button2.toggled.connect(_on_button_changed)
	_update_offsets()
	for i in 4:
		inputs[i].value_changed.connect(_on_input_changed.bind(i))


func _on_input_changed(new_value :float, index: int) -> void:
	var new_delta := floori(inputs[index].value) - _offsets[index]
	
	var range :Array
	if button_pressed:
		range = range(0,4)
	elif index < 2 and button1.button_pressed:
		range = range(0, 2)
	elif index > 1 and button2.button_pressed:
		range = range(2,4)
	
	for i in range:
		if i == index:
			continue
		inputs[i].set_value_no_signal(maxi(0, new_delta + _offsets[i]))
	
	_update_offsets()


func _on_button_changed(toggled_on: bool) -> void:
	if ! toggled_on:
		set_pressed_no_signal(false)
	_update_offsets()


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		button1.set_pressed_no_signal(true)
		button2.set_pressed_no_signal(true)
	_update_offsets()


func _update_offsets() -> void:
	_offsets.resize(inputs.size())
	
	var ranges :Array[Array] = []
	if button_pressed:
		ranges.append(range(0,4))
	else:
		if button1.button_pressed:
			ranges.append(range(0, 2))
		if button2.button_pressed:
			ranges.append(range(2,4))
	
	for range in ranges:
		var values :Array[int] = []
		for i in range:
			values.append(floori(inputs[i].value))
		var min := floori(values.min())
		for i in range:
			_offsets[i] = roundi(inputs[i].value) - min
