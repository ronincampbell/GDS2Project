extends Node3D

@export var downward_raycasts: Array[RayCast3D]
var prop: PackedScene = preload("res://Props/prop_plant.tscn")

const speed : float = 0.05

func _physics_process(delta: float) -> void:
	if !downward_raycasts.is_empty():
		var touching_ground = false
		
		for ray in downward_raycasts:
			if ray.is_colliding():
				touching_ground = true
		
		if !touching_ground:
			global_position += Vector3(0, -speed, 0)
	
	if Input.is_action_just_pressed("ui_accept"):
		var new_prop = prop.instantiate()
		new_prop.position = position
		new_prop.rotation = rotation
		print_debug(new_prop)
		print_debug(new_prop.position)
		get_parent().add_child(new_prop)
		queue_free()
