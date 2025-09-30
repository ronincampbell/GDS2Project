extends Control

@onready var players = [
	$PlayersMarginContainer/PlayersContainer/TopRowContainer/Player1,
	$PlayersMarginContainer/PlayersContainer/TopRowContainer/Player2,
	$PlayersMarginContainer/PlayersContainer/BottomRowContainer/Player3,
	$PlayersMarginContainer/PlayersContainer/BottomRowContainer/Player4
]
@onready var score_announce = $ScoreAnnouncePanel/AnnounceMargin/ScoreAnnounceText

func _ready() -> void:
	init_hud()

func _process(delta: float) -> void:
	if self.visible:
		for player in players:
			if player.is_timer_active:
				player.update_timer()
		
		for player in players:
			player.update_arrow()

func update_score(player_id: int, new_score: int):
	players[player_id].set_score_text(new_score)
	
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
	players[player_id].update_timer(stun_length, is_down)

func reset_score_announce():
	score_announce.get_parent().get_parent().hide()
	score_announce.text = "Scored!"

func reset_scores_ui():
	for player in players:
		player.set_score_text(0)

func reset_incap_ind():
	for player in players:
		player.reset_timer()

func update_player_icons(players_in: Array[bool]):
	for i in players_in.size():
		var is_player_in: bool = players_in[i]
		if is_player_in:
			players[i].show()
		else:
			players[i].hide()
