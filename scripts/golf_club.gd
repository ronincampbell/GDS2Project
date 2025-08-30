class_name GolfClub
extends RigidBody3D

@onready var handle_marker: Marker3D = $HandleMarker
@onready var head_marker: Marker3D = $HeadMarker

func get_handle_force_offset():
	return handle_marker.global_position - global_position

func get_handle_global_pos():
	return handle_marker.global_position

func get_head_force_offset():
	return head_marker.global_position - global_position

func get_head_global_pos():
	return head_marker.global_position
