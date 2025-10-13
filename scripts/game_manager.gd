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

@onready var prop_placement_ui: Node = $PropPlacement
#@onready var hud: Node = $Hud

var players_in_scene: int = 1
enum players_prop {PLAYER1, PLAYER2, PLAYER3, PLAYER4}

@onready var camera_controller : Camera3D = $Camera3D

var player_current_props = {
	players_prop.PLAYER1: "plant",
	players_prop.PLAYER2: "plant",
	players_prop.PLAYER3: "plant",
	players_prop.PLAYER4: "plant"
}
const player_prop_index = [players_prop.PLAYER1, players_prop.PLAYER2, players_prop.PLAYER3, players_prop.PLAYER4]
const prop_index = ["plant", "fertiliser", "watering_can"]
var current_player_prop_index = [0, 0, 0, 0]
var prop_preview_in_scene = [null, null, null, null]

func _ready() -> void:
	if ControllerManager.device_players.values().size() > 0:
		players_in_scene = ControllerManager.device_players.values().size()

func _physics_process(delta: float) -> void:
	if mode == "obstacle placing":
		obstacle_placing_timer += delta
		prop_placement_ui.update_timer_text(snappedf(obstacle_placing_time-obstacle_placing_timer, 0.1))
		
		if Input.is_action_just_pressed("ui_accept"):
			skip_placing = true
		
		if obstacle_placing_timer > obstacle_placing_time or skip_placing:
			prop_placement_ui.visible = false
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
				new_gnome.add_to_group("Players")
				available_spawns.remove_at(spawn_index)
			
			for marker in available_spawns:
				marker.set_visibility(false)
			
			#_place_object(golf_club, Vector3(-0.6, 1.6, 0.4))
			#var new_gnome = _place_object(gnome, Vector3(0, 1.4, 0))
			#new_gnome.player_num = 1
		
		##if !prop_preview_in_scene[0]:
			##_place_player_object(player_current_props[players_prop.PLAYER1], 1)
		
		for i in players_in_scene:
			if !prop_preview_in_scene[i]:
				_place_player_object(player_current_props[player_prop_index[i]], i+1)
			
			var index_change = 0
			if Input.is_action_just_pressed("NextObject"+str(i+1)):
				index_change += 1
			if Input.is_action_just_pressed("PreviousObject"+str(i+1)):
				index_change -= 1
			
			if index_change != 0:
				prop_preview_in_scene[i].queue_free()
				
				current_player_prop_index[i] += index_change
				if current_player_prop_index[i] < 0:
					current_player_prop_index[i] = prop_index.size()-1
				elif current_player_prop_index[i] >= prop_index.size():
					current_player_prop_index[i] = 0
				
				var new_prop = prop_index[current_player_prop_index[i]]
				player_current_props[player_prop_index[i]] = new_prop
				_place_player_object(new_prop, i+1)
				prop_placement_ui.update_selected(i+1, new_prop)

func _place_player_object(player_current_prop, player_num) -> void:
	var new_prop = _place_object(placeable_props[player_current_prop], Vector3(0, 1.6, 0))
	if new_prop.has_method("set_player"):
		new_prop.set_player(player_num)
	prop_preview_in_scene[player_num-1] = new_prop
	
	if camera_controller.has_method("update_targets"):
		camera_controller.update_targets()

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
