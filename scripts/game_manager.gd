extends Node

var score : int = 0

@export
var skip_placing: bool = false

var mode : String = "obstacle placing"
var obstacle_placing_timer : float = 0
var obstacle_placing_time : float = 60                                                    
var player1_obstacle_in_scene : bool = false

const placeable_props: Dictionary = {"plant":preload("res://Props/Previews/prop_plant_preview.tscn"), "fertiliser":preload("res://Props/Previews/prop_fertiliser_preview.tscn"), "watering_can":preload("res://Props/Previews/prop_watering_can_preview.tscn")}
const golf_ball: PackedScene = preload("res://CoreObjects/golf_ball.tscn")
const golf_club: PackedScene = preload("res://CoreObjects/golf_club.tscn")
const gnome: PackedScene = preload("res://CoreObjects/gnome.tscn")

const ball_spawn_offset: Vector3 = Vector3(0,0.7,0)
const club_spawn_offset: Vector3 = Vector3(0,1.6,0)
const gnome_spawn_offset: Vector3 = Vector3(0,1.4,0)

func _physics_process(delta: float) -> void:
	if mode == "obstacle placing":
		obstacle_placing_timer += delta
		
		if Input.is_action_just_pressed("ui_accept"):
			skip_placing = true
		
		if obstacle_placing_timer > obstacle_placing_time or skip_placing:
			mode = "playing"
			for marker in get_tree().get_nodes_in_group("BallSpawnMarkers"):
				_place_object(golf_ball, marker.global_position+ball_spawn_offset)
			for marker in get_tree().get_nodes_in_group("ClubSpawnMarkers"):
				_place_object(golf_club, marker.global_position+club_spawn_offset)
			var available_spawns: Array = get_tree().get_nodes_in_group("PlayerSpawnMarkers")
			for player_num in ControllerManager.device_players.values():
				var spawn_index: int = randi_range(0, available_spawns.size()-1)
				var new_gnome = _place_object(gnome, available_spawns[spawn_index].global_position + gnome_spawn_offset)
				new_gnome.player_num = player_num
				available_spawns.remove_at(spawn_index)
			
			#_place_object(golf_club, Vector3(-0.6, 1.6, 0.4))
			#var new_gnome = _place_object(gnome, Vector3(0, 1.4, 0))
			#new_gnome.player_num = 1
		
		if !player1_obstacle_in_scene:
			var new_prop = _place_object(pick_random(placeable_props), Vector3(0, 1.6, 0))
			if new_prop.has_method("set_player"):
				new_prop.set_player(1)
			player1_obstacle_in_scene = true

func _on_golf_hole_entered(body: Node3D) -> void:
	if body.name == "GolfBall":
		body.position = Vector3(2.414, 0.668, -2.318)
		if body.has_method("reset_velocity"):
			body.reset_velocity()
		score += 1
		Hud.update_score(0, score)
		SoundPlayer.play_ball_in_hole()
		if(score >= 3):
			body.queue_free()
			print_debug("Game won!")

func _place_object(object: PackedScene, pos: Vector3) -> Node:
	var new_object = object.instantiate()
	new_object.position = pos
	add_child(new_object)
	return new_object

func prop_placed() -> void:
	player1_obstacle_in_scene = false

func pick_random(dictionary: Dictionary) -> Variant:
	var random_key = dictionary.keys().pick_random()
	return dictionary[random_key]
