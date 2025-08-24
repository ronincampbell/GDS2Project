extends RigidBody3D

func _physics_process(delta: float) -> void:
	var flat_move_dir: Vector2 = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	var move_dir: Vector3 = Vector3(flat_move_dir.x, 0.0, flat_move_dir.y)
	apply_central_force(move_dir * 10.0)
