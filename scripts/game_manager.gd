extends Node


func _on_golf_hole_entered(body: Node3D) -> void:
	if(body.name == "GolfBall"):
		print_debug("Golf ball in hole")
		body.position = Vector3(2.414, 0.668, -2.318)
