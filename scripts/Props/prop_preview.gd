extends Node3D

@export var downward_raycasts: Array[RayCast3D]
@export var side_raycasts: Array[RayCast3D]
var prop: PackedScene = preload("res://Props/prop_plant.tscn")

const speed : float = 5

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_accept"):
		place_prop()
	
	_move_prop(delta)

func _move_prop(delta: float) -> void:
	if !downward_raycasts.is_empty():
		var touching_ground = false
		
		for ray in downward_raycasts:
			if ray.is_colliding():
				touching_ground = true
		
		if !touching_ground:
			position += Vector3(0, -1, 0)*delta*speed
	
	var direction: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("ui_left") and !is_ray_colliding(side_raycasts[3]):
		direction += Vector3(-1, 0, 0)
	if Input.is_action_pressed("ui_right") and !is_ray_colliding(side_raycasts[1]):
		direction += Vector3(1, 0, 0)
	if Input.is_action_pressed("ui_up") and !is_ray_colliding(side_raycasts[0]):
		direction += Vector3(0, 0, -1)
	if Input.is_action_pressed("ui_down") and !is_ray_colliding(side_raycasts[2]):
		direction += Vector3(0, 0, 1)
	
	position += direction.normalized()*speed*delta

func place_prop() -> void:
	var new_prop = prop.instantiate()
	new_prop.position = position
	new_prop.rotation = rotation
	#print_debug(new_prop)
	#print_debug(new_prop.position)
	get_parent().add_child(new_prop)
	queue_free()

func is_ray_colliding(ray: RayCast3D) -> bool:
	if !ray.is_colliding():
		return false
	
	if "Barrier" in ray.get_collider().name:
		return true
	
	return false
