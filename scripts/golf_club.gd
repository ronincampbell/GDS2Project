class_name GolfClub
extends RigidBody3D

@onready var handle_marker: Marker3D = $HandleMarker
@onready var head_marker: Marker3D = $HeadMarker

var is_held: bool = false

var held_linear_damping: float = 2.0
var free_linear_damping: float = 0.3
var held_angular_damping: float = 2.0
var free_angular_damping: float = 0.3

var spawn_pos: Vector3 = Vector3.ZERO

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if spawn_pos == Vector3.ZERO:
		spawn_pos = global_position
	if global_position.y < -10:
		global_position = spawn_pos
	if is_held:
		for player in PlayerManager.player_nodes:
			if player.arm_state == Gnome.ArmState.CLUB or player.arm_state == Gnome.ArmState.AIMING:
				return
		is_held = false

func get_handle_force_offset():
	return handle_marker.global_position - global_position

func get_handle_global_pos():
	return handle_marker.global_position

func get_head_force_offset():
	return head_marker.global_position - global_position

func get_head_global_pos():
	return head_marker.global_position

func enable_held_damping():
	linear_damp = held_linear_damping
	angular_damp = held_angular_damping

func disable_held_damping():
	linear_damp = free_linear_damping
	angular_damp = free_angular_damping
