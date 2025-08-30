extends Node

var score : int = 0

@export var mode : String = "obstacle placing"
var obstacle_placing_timer : float = 0
var obstacle_placing_time : float = 30                                                       
var player1_obstacle_in_scene : bool = false

var prop_preview: PackedScene = preload("res://Props/Previews/prop_plant_preview.tscn")

func _physics_process(delta: float) -> void:
	if mode == "obstacle placing":
		obstacle_placing_timer += delta
		
		if obstacle_placing_timer > obstacle_placing_time:
			mode = "playing"
		
		if !player1_obstacle_in_scene:
			_place_prop_preview()

func _on_golf_hole_entered(body: Node3D) -> void:
	if body.name == "GolfBall":
		body.position = Vector3(2.414, 0.668, -2.318)
		score += 1
		Hud.update_score(0, score)
		if(score >= 3):
			print_debug("Game won!")

func _place_prop_preview() -> void:
	var new_prop = prop_preview.instantiate()
	new_prop.position = Vector3(0, 1.2, 0)
	add_child(new_prop)
	player1_obstacle_in_scene = true

func prop_placed() -> void:
	player1_obstacle_in_scene = false
