extends Control

@onready var players = [
	$PlayersContainer/TopRowContainer/Player1,
	$PlayersContainer/TopRowContainer/Player2,
	$PlayersContainer/BottomRowContainer/Player3,
	$PlayersContainer/BottomRowContainer/Player4
]
@onready var player_scores = [
	$PlayersContainer/TopRowContainer/Player1/ScoreContainer/ScoreMargin/ScoreText,
	$PlayersContainer/TopRowContainer/Player2/ScoreContainer2/ScoreMargin/ScoreText,
	$PlayersContainer/BottomRowContainer/Player3/ScoreContainer3/ScoreMargin/ScoreText,
	$PlayersContainer/BottomRowContainer/Player4/ScoreContainer4/ScoreMargin/ScoreText
]
@onready var score_announce = $ScoreAnnouncePanel/AnnounceMargin/ScoreAnnounceText
@onready var incap_indicators = $IncapIndicators

func _ready() -> void:
	init_hud()

func update_score(player_id: int, new_score: int):
	player_scores.get(player_id).text = str(new_score)
	
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

func indicate_player_incapicated(player_id: int, is_down: bool):
	if is_down:
		incap_indicators.get_child(player_id).show()
	else:
		incap_indicators.get_child(player_id).hide()

func reset_score_announce():
	score_announce.get_parent().get_parent().hide()
	score_announce.text = "Scored!"

func reset_scores_ui():
	for score in player_scores:
		score.text = "0"

func reset_incap_ind():
	for indi in incap_indicators.get_children():
		indi.hide()

func update_player_icons(players_in: Array[bool]):
	for i in players_in.size():
		var is_player_in: bool = players_in[i]
		if is_player_in:
			players[i].show()
		else:
			players[i].hide()
