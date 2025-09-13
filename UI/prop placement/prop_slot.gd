extends TextureRect
@onready var prop_container = $SubViewport/PropContainer

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
