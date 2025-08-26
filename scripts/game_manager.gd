extends Node

var score : int = 0

func _on_golf_hole_entered(body: Node3D) -> void:
	if(body.name == "GolfBall"):
		body.position = Vector3(2.414, 0.668, -2.318)
		score += 1
		Hud.update_score(score)
		if(score >= 3):
			print_debug("Game won!")
