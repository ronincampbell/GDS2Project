extends Node
var players_in :Array[bool] = [false, false, false, false]
var players_ready :Array[bool] = [false, false, false, false]

var maps: Dictionary = {0: "test_map", 1: "map2", 2: "map3"}

@onready var gnome_laugh: AudioStreamPlayer = $GnomeLaugh

@onready var map_selector = $"../LobbyHud/MarginContainer/MainContainer/PanelContainer/MarginContainer/HBoxContainer/LobbySettings/HBoxContainer/MapSelector"
@onready var point_limit_selector = $"../LobbyHud/MarginContainer/MainContainer/PanelContainer/MarginContainer/HBoxContainer/LobbySettings/HBoxContainer2/PointLimitSelector"

func drop_in_player(player_num: int):
	get_node("%PhysicsP" + str(player_num)).freeze = false
	get_node("%ReadyP" + str(player_num)).text = "Not Ready"
	players_in[player_num-1] = true
	gnome_laugh.play()

func remove_player(player_num: int):
	get_node("%PhysicsP" + str(player_num)).freeze = true
	players_in[player_num-1] = false
	players_ready[player_num-1] = false
	get_node("%ReadyP" + str(player_num)).text = "INACTIVE"
	await get_tree().process_frame
	get_node("%PhysicsP" + str(player_num)).position.y = 11

func next_scene():
	Hud.show()
	AudioManager.stop_lobby_music()
	AudioManager.play_gameplay_music()
	LobbyManager.point_limit = point_limit_selector.current_index + 1
	var map_index: int = map_selector.current_index
	get_tree().change_scene_to_file("res://maps/"+maps[map_index]+".tscn")

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
	AudioManager.play_lobby_music()
	ControllerManager.device_joined.connect(_on_device_joined)
	ControllerManager.device_left.connect(_on_device_left)
	map_selector.prev_button.grab_focus()

func _input(event: InputEvent) -> void:
	for i in range(1,5):
		if event.is_action_pressed("PlayerAttack"+str(i)):
			ready_player(i)
			break
		elif event.is_action_pressed("PlayerCancel"+str(i)):
			unready_player(i)
			break

func _on_device_joined(player: int, device: int):
	drop_in_player(player)

func _on_device_left(player: int, device: int):
	remove_player(player)
