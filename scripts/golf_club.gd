class_name GolfClub
extends RigidBody3D

@onready var handle_marker: Marker3D = $HandleMarker
@onready var head_marker: Marker3D = $HeadMarker

var is_held: bool = false

var held_linear_damping: float = 2.0
var free_linear_damping: float = 0.3
var held_angular_damping: float = 2.0
var free_angular_damping: float = 0.3

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
