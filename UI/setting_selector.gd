extends HBoxContainer

@export
var start_index: int
@export
var text_values: Array[String]
@export
var allow_wraparound: bool = false

var current_index: int = 0:
	set(value):
		current_index = value
		if current_index < 0:
			if allow_wraparound:
				current_index = text_values.size()-1
			else:
				current_index = 0
		if current_index >= text_values.size():
			if allow_wraparound:
				current_index = 0
			else:
				current_index = text_values.size()-1
		selected_label.text = text_values[current_index]

@onready var prev_button = $PrevButton
@onready var next_button = $NextButton
@onready var selected_label = $SelectedLabel

func _ready():
	current_index = start_index
	validate_buttons()

func validate_buttons():
	if !allow_wraparound and current_index <= 0:
		prev_button.disabled = true
	if current_index > 0:
		prev_button.disabled = false
	
	if !allow_wraparound and current_index >= text_values.size()-1:
		next_button.disabled = true
	if current_index < text_values.size()-1:
		next_button.disabled = false

func _on_prev_button_pressed():
	current_index -= 1
	validate_buttons()

func _on_next_button_pressed():
	current_index += 1
	validate_buttons()

func get_text_value() -> String:
	return text_values[current_index]
