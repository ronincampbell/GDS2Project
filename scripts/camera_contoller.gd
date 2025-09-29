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
	
	mid_pos /= targets.size()
	
	print_debug("mid pos: "+str(mid_pos))
	print_debug("amt of targets: "+str(targets.size()))
