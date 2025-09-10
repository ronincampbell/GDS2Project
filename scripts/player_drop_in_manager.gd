extends Node
var players_in :Array[bool] = [false, false, false, false]
var players_ready :Array[bool] = [false, false, false, false]

func drop_in_player(player_num: int):
	get_node("%PhysicsP" + str(player_num)).freeze = false
	players_in[player_num-1] = true

func remove_player(player_num: int):
	get_node("%PhysicsP" + str(player_num)).freeze = true
	get_node("%PhysicsP" + str(player_num)).position.y = 11
	players_in[player_num-1] = false
	players_ready[player_num-1] = false
	get_node("%ReadyP" + str(player_num)).text = "Not Ready"

func next_scene():
	Hud.show()
	get_tree().change_scene_to_file("res://maps/test_map.tscn")

func all_ready() -> bool:
	if players_in.all(func(value):return value == false):
		return false
	for i in 4:
		if players_in[i] and !players_ready[i]:
			return false
	return true

func ready_player(player_num: int):
	players_ready[player_num-1] = true
	get_node("%ReadyP" + str(player_num)).text = "Ready"
	if all_ready():
		next_scene()

func unready_player(player_num: int):
	players_ready[player_num-1] = false
	get_node("%ReadyP" + str(player_num)).text = "Not Ready"

func _ready() -> void:
	Hud.hide()
