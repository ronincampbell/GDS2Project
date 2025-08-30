extends RigidBody3D

const move_force: float = 15.0
const max_walk_speed: float = 3.0

func _integrate_forces(state):
	var flat_move_dir: Vector2 = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	var move_dir: Vector3 = Vector3(flat_move_dir.x, 0.0, flat_move_dir.y)
	
	var flat_speed: Vector3 = linear_velocity
	flat_speed.y = 0.0
	if move_dir.dot(flat_speed.normalized()) > 0.3:
		if flat_speed.length() < max_walk_speed:
			apply_central_force(move_dir*move_force)
	else:
		apply_central_force(move_dir*move_force)
	print(linear_velocity.length())
