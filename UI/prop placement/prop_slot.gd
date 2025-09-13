extends TextureRect

@onready var prop_container = $SubViewport/PropContainer
@onready var player_panels = [
	$VBoxContainer/HBoxContainer/Player1,
	$VBoxContainer/HBoxContainer/Player2,
	$VBoxContainer/HBoxContainer2/Player3,
	$VBoxContainer/HBoxContainer2/Player4
]

func _process(delta):
	prop_container.rotate_y(1 * delta)

func set_slot_prop(object: PackedScene):
	for prop in prop_container.get_children():
		prop.queue_free()
	
	var prop = object.instantiate()
	prop_container.add_child(prop)
	prop.axis_lock_linear_x = true
	prop.axis_lock_linear_y = true
	prop.axis_lock_linear_z = true

func clear_selections():
	for panel in player_panels:
		panel.hide()

func set_selections(player_index: int):
	player_panels.get(player_index).show()
