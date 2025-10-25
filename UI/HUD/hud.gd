extends Control

@onready var player_containers = [
	$PlayersMarginContainer/PlayersContainer/TopRowContainer/Player1,
	$PlayersMarginContainer/PlayersContainer/TopRowContainer/Player2,
	$PlayersMarginContainer/PlayersContainer/BottomRowContainer/Player3,
	$PlayersMarginContainer/PlayersContainer/BottomRowContainer/Player4
]
@onready var score_announce_panel = $ScoreAnnouncePanel
@onready var score_announce_text = $ScoreAnnouncePanel/MarginContainer/PanelContainer/AnnounceMargin/ScoreAnnounceText
@onready var scoreboard = $Scoreboard
var current_scene: Node
var players: Array

func _ready() -> void:
	PlayerManager.player_got_club.connect(_on_player_got_club)
	PlayerManager.player_lost_club.connect(_on_player_lost_club)
	PlayerManager.player_disabled.connect(_on_player_disabled)
	PlayerManager.player_stunned.connect(_on_player_stunned)
	init_hud(true)

func _process(_delta: float) -> void:
	if self.visible:
		update_player_arrows()
		
		for container in player_containers:
			if container.is_timer_active:
				container.update_timer()
	
func init_hud(reset_scores: bool):
	reset_stun_timer()
	reset_spells_ui()
	init_player_icons()
	if reset_scores:
		reset_score_announce()
		reset_scores_ui()
		reset_scoreboard()
	current_scene = get_tree().current_scene

func announce_score(player_id: int):
	score_announce_panel.show()
	score_announce_text.text = "Player " + str(player_id) + " Scored!"

func reset_score_announce():
	score_announce_panel.hide()
	score_announce_text.text = "Player # Scored!"

func reset_scores_ui():
	for container in player_containers:
		container.set_score_text(0)

func reset_stun_timer():
	for container in player_containers:
		container.reset_timer()

func reset_scoreboard():
	scoreboard.reset_scoreboard()
	scoreboard.hide()

func reset_spells_ui():
	for container in player_containers:
		container.update_spell()

func init_player_icons():
	for container in player_containers:
		container.hide()
	var players_in = PlayerManager.get_num_players_on_field()
	for player in players_in:
		player_containers[player].show()
		players.push_back(PlayerManager.get_player_node(player))

func update_score(player_id: int, new_score: int):
	player_containers[player_id].set_score_text(new_score)
	scoreboard.update_scoreboard(player_id, new_score)

func update_player_arrows():
	for player in players:
		var container
		if player:
			container = player_containers[player.player_num-1]
		if container and container.visible and player and current_scene:
				container.update_arrow(player.position, current_scene.get_viewport().get_camera_3d())

func update_player_spell_icon(player_id: int = -1, spell: int = -1):
	if player_id> -1:
		player_containers[clamp(player_id-1, 0, 3)].update_spell(spell)

func show_scoreboard():
	scoreboard.show()

func hide_icons():
	for container in player_containers:
		container.hide()

func _on_player_got_club(player_num: int):
	player_containers[player_num-1].update_crown(true)

func _on_player_lost_club(player_num: int):
	player_containers[player_num-1].update_crown(false)

func _on_player_disabled(player_num: int):
	if !PlayerManager.player_nodes.is_empty():
		player_containers[player_num-1].update_timer(PlayerManager.get_player_disable_time(player_num-1), true)

func _on_player_stunned(player_num: int):
	player_containers[player_num-1].update_timer(PlayerManager.get_player_stun_time(player_num-1), true)
