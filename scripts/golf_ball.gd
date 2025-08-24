extends RigidBody3D

const hit_power: float = 200
const lift_force: float = 200
const max_move_speed: float = 10
const max_spin_speed: float = 16

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if Input.is_action_just_pressed("ui_left"):
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
		apply_central_force(Vector3.BACK*hit_power+Vector3.UP*lift_force)
	state.linear_velocity.limit_length(max_move_speed)
	state.angular_velocity.limit_length(max_spin_speed)
