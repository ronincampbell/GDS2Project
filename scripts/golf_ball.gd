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

var is_being_aimed: bool = false
var last_hit_player: int = -1
@export
var color_models: Array[Node3D]

var spawn_pos: Vector3 = Vector3.ZERO


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity.limit_length(max_move_speed)
	state.angular_velocity.limit_length(max_spin_speed)
	if spawn_pos == Vector3.ZERO:
		spawn_pos = global_position
	if global_position.y < -10:
		global_position = spawn_pos
	
	if is_being_aimed:
		for player in PlayerManager.player_nodes:
			if player.arm_state == Gnome.ArmState.AIMING:
				return
		is_being_aimed = false

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

func aim_with_force(force: float):
	#aim_decal.scale = Vector3(force, force, force)
	aim_decal.size = Vector3(2*force, 10, 2*force)
	aim_decal.position.x = 1.15722*force

func launch_in_aim_direction(force: float, launching_player: int):
	for model in color_models:
		model.hide()
	last_hit_player = launching_player
	color_models[last_hit_player].show()
	if stored_aim_dir.is_zero_approx():
		return
	angular_velocity = Vector3.ZERO
	var aim_vector: Vector3 = Vector3(stored_aim_dir.x, 0.0, stored_aim_dir.y)
	apply_central_impulse(aim_vector*hit_power*force + Vector3.UP*lift_force*force)

func reset_velocity():
	angular_velocity = Vector3.ZERO
	linear_velocity = Vector3.ZERO
