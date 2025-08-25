extends RigidBody3D

const hit_power: float = 200
const lift_force: float = 200
const max_move_speed: float = 10
const max_spin_speed: float = 16

@onready var y_rotate_pivot = $NoRotatePivot/YRotatePivot
@onready var aim_decal = $NoRotatePivot/YRotatePivot/AimDecal

var stored_aim_dir: Vector2 = Vector2.ZERO

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	"""if Input.is_action_just_pressed("ui_left"):
		state.angular_velocity = Vector3.ZERO
		apply_central_force(Vector3.LEFT*hit_power+Vector3.UP*lift_force)
	if Input.is_action_just_pressed("ui_right"):
		state.angular_velocity = Vector3.ZERO
		apply_central_force(Vector3.RIGHT*hit_power+Vector3.UP*lift_force)
	if Input.is_action_just_pressed("ui_up"):
		state.angular_velocity = Vector3.ZERO
		apply_central_force(Vector3.FORWARD*hit_power+Vector3.UP*lift_force)
	if Input.is_action_just_pressed("ui_down"):
		state.angular_velocity = Vector3.ZERO
		apply_central_force(Vector3.BACK*hit_power+Vector3.UP*lift_force)"""
	
	var flat_aim_vector: Vector2 = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	if flat_aim_vector.is_zero_approx():
		flat_aim_vector = stored_aim_dir
	else:
		stored_aim_dir = flat_aim_vector
	
	if Input.is_action_pressed("ui_accept"):
		aim_decal.show()
		y_rotate_pivot.rotation.y = -flat_aim_vector.angle()
	else:
		aim_decal.hide()
	if Input.is_action_just_released("ui_accept") and !flat_aim_vector.is_zero_approx():
		state.angular_velocity = Vector3.ZERO
		var aim_vector: Vector3 = Vector3(flat_aim_vector.x, 0.0, flat_aim_vector.y)
		apply_central_force(aim_vector*hit_power + Vector3.UP*lift_force)
	
	state.linear_velocity.limit_length(max_move_speed)
	state.angular_velocity.limit_length(max_spin_speed)
