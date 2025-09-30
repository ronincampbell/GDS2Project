extends Control

@onready var player_containers = [
	$PlayersMarginContainer/PlayersContainer/TopRowContainer/Player1,
	$PlayersMarginContainer/PlayersContainer/TopRowContainer/Player2,
	$PlayersMarginContainer/PlayersContainer/BottomRowContainer/Player3,
	$PlayersMarginContainer/PlayersContainer/BottomRowContainer/Player4
]
@onready var score_announce = $ScoreAnnouncePanel/AnnounceMargin/ScoreAnnounceText
var current_scene: Node
var players: Array

func _ready() -> void:
	init_hud()

func _process(delta: float) -> void:
	if self.visible:
		if players.is_empty():
			if current_scene:
				for node in current_scene.get_children():
					if node.is_in_group("Players"):
						players.push_back(node)
		else:
			for container in player_containers:
				if container.visible:
					container.update_arrow(players[container.get_index()].position, current_scene.get_viewport().get_camera_3d())
		
		for container in player_containers:
			if container.is_timer_active:
				container.update_timer()

	
	if current_scene != get_tree().current_scene:
		current_scene = get_tree().current_scene

func update_score(player_id: int, new_score: int):
	player_containers[player_id].set_score_text(new_score)
	
func init_hud():
	#reset score texts
	reset_scores_ui()
	#reset score announcement
	reset_score_announce()
	#hide incapicated indicators
	reset_incap_ind()

func announce_score(player_id: int):
	score_announce.get_parent().get_parent().show()
	score_announce.text = "Player " + str(player_id) + " Scored!"

func indicate_player_incapicated(player_id: int, is_down: bool, stun_length: float):
	player_containers[player_id].update_timer(stun_length, is_down)

func reset_score_announce():
	score_announce.get_parent().get_parent().hide()
	score_announce.text = "Scored!"

func reset_scores_ui():
	for container in player_containers:
		container.set_score_text(0)

func reset_incap_ind():
	for container in player_containers:
		container.reset_timer()

func update_player_icons(players_in: Array[bool]):
	for i in players_in.size():
		var is_player_in: bool = players_in[i]
		if is_player_in:
			player_containers[i].show()
		else:
			player_containers[i].hide()
