extends Node3D

@export var downward_raycasts: Array[RayCast3D]
@export var side_raycasts: Array[RayCast3D]
@export var prop: PackedScene = preload("res://Props/prop_plant.tscn")
@onready var model: Node3D = $blockbench_export
@onready var model_cannot_place = $blockbench_export2
var in_area: int = 0
var can_place: bool = true
var player_num: int = -1

const speed : float = 5
const rotate_speed : float = 5

func _physics_process(delta: float) -> void:
	
	if get_parent().mode == "playing":
		queue_free()
	
	if Input.is_action_just_pressed("PlayerInteract"+str(player_num)) and can_place:
		place_prop()
	
	_move_prop(delta)
	_rotate_prop(delta)

func set_player(num: int) -> void:
	player_num = num

func _move_prop(delta: float) -> void:
	if !downward_raycasts.is_empty():
		var touching_ground = false
		
		for ray in downward_raycasts:
			if ray.is_colliding():
				touching_ground = true
				
				var origin = ray.global_position
				var collision_point = ray.get_collision_point()
				
				if origin.distance_to(collision_point) < 0.1:
					position += Vector3(0, 1, 0)*delta*speed
		
		if !touching_ground:
			position += Vector3(0, -1, 0)*delta*speed
	
	var direction: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("PlayerLeft"+str(player_num)) and !_is_ray_colliding(side_raycasts[3]):
		direction += Vector3(-1, 0, 0)
	if Input.is_action_pressed("PlayerRight"+str(player_num)) and !_is_ray_colliding(side_raycasts[1]):
		direction += Vector3(1, 0, 0)
	if Input.is_action_pressed("PlayerUp"+str(player_num)) and !_is_ray_colliding(side_raycasts[0]):
		direction += Vector3(0, 0, -1)
	if Input.is_action_pressed("PlayerDown"+str(player_num)) and !_is_ray_colliding(side_raycasts[2]):
		direction += Vector3(0, 0, 1)
	
	position += direction.normalized()*speed*delta

func place_prop() -> void:
	var new_prop = prop.instantiate()
	new_prop.position = position
	new_prop.rotation = model.rotation
	#print_debug(new_prop)
	#print_debug(new_prop.position)
	get_parent().add_child(new_prop)
	if get_parent().has_method("prop_placed"):
		get_parent().prop_placed()
	queue_free()

func _is_ray_colliding(ray: RayCast3D) -> bool:
	if !ray.is_colliding():
		return false
	
	if "Barrier" in ray.get_collider().name:
		return true
	
	return false

func _rotate_prop(delta: float) ->  void:
	var _rotate = Vector3.ZERO
	
	if Input.is_action_pressed("RotateClock"+str(player_num)):
		_rotate += Vector3(0, delta*rotate_speed, 0)
	if Input.is_action_pressed("RotateAntiClock"+str(player_num)):
		_rotate += Vector3(0, -delta*rotate_speed, 0)
	
	model.rotation += _rotate
	model_cannot_place.rotation = model.rotation


func _on_body_entered(_body: Node3D) -> void:
	in_area += 1
	can_place = false
	model.hide()
	model_cannot_place.show()

func _on_body_exited(_body: Node3D) -> void:
	in_area -= 1
	if in_area < 1:
		can_place = true
		model.show()
		model_cannot_place.hide()

func _on_area_entered(area: Area3D) -> void:
	in_area += 1
	can_place = false
	model.hide()
	model_cannot_place.show()

func _on_area_exited(area: Area3D) -> void:
	in_area -= 1
	if in_area < 1:
		can_place = true
		model.show()
		model_cannot_place.hide()
