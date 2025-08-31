class_name GolfBall
extends RigidBody3D

const hit_power: float = 5
const lift_force: float = 5
const max_move_speed: float = 10
const max_spin_speed: float = 16

@onready var y_rotate_pivot = $NoRotatePivot/YRotatePivot
@onready var aim_decal = $NoRotatePivot/YRotatePivot/AimDecal

var stored_aim_dir: Vector2 = Vector2.ZERO
var showing_aim_arrow: bool = false

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity.limit_length(max_move_speed)
	state.angular_velocity.limit_length(max_spin_speed)

func show_aim_arrow():
	showing_aim_arrow = true

func hide_aim_arrow():
	showing_aim_arrow = false
	aim_decal.hide()
	stored_aim_dir = Vector2.ZERO

func get_3d_aim_dir():
	return Vector3(stored_aim_dir.x, 0.0, stored_aim_dir.y)

func aim_in_dir(direction: Vector3):
	var flat_direction: Vector2 = Vector2(direction.x, direction.z)
	if flat_direction.is_zero_approx():
		return
	aim_decal.show()
	stored_aim_dir = flat_direction
	
	y_rotate_pivot.rotation.y = -flat_direction.angle()

func launch_in_aim_direction():
	if stored_aim_dir.is_zero_approx():
		return
	angular_velocity = Vector3.ZERO
	var aim_vector: Vector3 = Vector3(stored_aim_dir.x, 0.0, stored_aim_dir.y)
	apply_central_impulse(aim_vector*hit_power + Vector3.UP*lift_force)
