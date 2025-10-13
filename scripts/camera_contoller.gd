extends Camera3D

const move_speed : float = 5
const max_zoom : float = 15
const min_zoom : float = 6

const camera_angle : float = 70
const distance_from_targets : float = 0.14

var targets : Array[Node] = []

func _physics_process(delta: float) -> void:
	if !targets.is_empty():
		if _has_empty_node():
			update_targets()
		
		move_camera(delta)

func _has_empty_node() -> bool:
	for target in targets:
		if target == null:
			return true
	
	return false

func update_targets() -> void:
	targets = get_tree().get_nodes_in_group("CameraTarget")

func move_camera(delta : float) -> void:
	var mid_pos : Vector3 = Vector3.ZERO
	var min_pos : Vector2 = Vector2(targets[0].global_position.x, targets[0].global_position.z)
	var max_pos : Vector2 = Vector2(targets[0].global_position.x, targets[0].global_position.z)
	
	for target in targets:
		if target.global_position.x < min_pos.x:
			min_pos.x = target.global_position.x
		
		if target.global_position.z < min_pos.y:
			min_pos.y = target.global_position.z
		
		if target.global_position.x > max_pos.x:
			max_pos.x = target.global_position.x
		
		if target.global_position.z > max_pos.y:
			max_pos.y = target.global_position.z

	
	var x_range : float = abs(max_pos.x-min_pos.x)
	var z_range : float = abs(max_pos.y-min_pos.y)
	
	mid_pos = Vector3(min_pos.x+max_pos.x, 0, min_pos.y+max_pos.y)/2
	
	var larger_range : float = z_range*9
	
	if x_range*16 > z_range*9:
		larger_range = x_range*16
	
	var distance_from_action : float = larger_range * distance_from_targets
	
	if distance_from_action > max_zoom:
		distance_from_action = max_zoom
	elif distance_from_action < min_zoom:
		distance_from_action = min_zoom
	
	rotation_degrees = Vector3(-camera_angle, 0, 0)
	var move_to_pos = Vector3(mid_pos.x, 
						distance_from_action*sin(deg_to_rad(camera_angle)), 
						distance_from_action*cos(deg_to_rad(camera_angle))+mid_pos.z)
	
	position = position.lerp(move_to_pos, delta*move_speed)
	
	if Input.is_key_pressed(KEY_K):
		print_debug("mid pos: "+str(mid_pos))
		print_debug("distance_from_action: "+str(distance_from_action))
		print_debug("amt of targets: "+str(targets.size()))
