extends Camera3D

const move_speed : float = 30
const zoom_speed : float = 3
const min_zoom : float = 5

var targets : Array[Node] = []

func _physics_process(delta: float) -> void:
	if !targets.is_empty():
		if _has_empty_node():
			update_targets()
		
		move_camera()

func _has_empty_node() -> bool:
	for target in targets:
		if target == null:
			return true
	
	return false

func update_targets() -> void:
	targets = get_tree().get_nodes_in_group("CameraTarget")

func move_camera() -> void:
	var mid_pos : Vector3 = Vector3.ZERO
	var min_pos : Vector2 = Vector2(targets[0].global_position.x, targets[0].global_position.y)
	var max_pos : Vector2 = Vector2(targets[0].global_position.x, targets[0].global_position.y)
	
	for target in targets:
		mid_pos += target.global_position
		
		if target.global_position.x < min_pos.x:
			min_pos.x = target.global_position.x
		
		if target.global_position.z < min_pos.y:
			min_pos.y = target.global_position.z
		
		if target.global_position.x > max_pos.x:
			max_pos.x = target.global_position.x
		
		if target.global_position.z > max_pos.y:
			max_pos.y = target.global_position.z
	
	mid_pos /= targets.size()
	
	var x_range : float = max_pos.x-min_pos.x
	var z_range : float = max_pos.y-min_pos.y
	
	var larger_range : float = z_range
	
	if x_range*16 > z_range*9:
		larger_range = x_range
	
	var distance_from_action : float = 0
	
	print_debug("mid pos: "+str(mid_pos))
	print_debug("x range: "+str(x_range))
	print_debug("z range: "+str(z_range))
	print_debug("amt of targets: "+str(targets.size()))
