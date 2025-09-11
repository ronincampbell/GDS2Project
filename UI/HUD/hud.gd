extends Control

#temporary variable until there's a proper method to get num of players
var player_count = 4

@onready var player_scores_container = $PlayerScores
@onready var player_scores = [
	$PlayerScores/ScoreContainer/ScoreMargin/ScoreText,
	$PlayerScores/ScoreContainer2/ScoreMargin/ScoreText,
	$PlayerScores/ScoreContainer3/ScoreMargin/ScoreText,
	$PlayerScores/ScoreContainer4/ScoreMargin/ScoreText
]
@onready var score_announce = $ScoreAnnouncePanel/AnnounceMargin/ScoreAnnounceText

func _ready() -> void:
	init_hud()

func update_score(player_id: int, new_score: int):
	player_scores.get(player_id).text = str(new_score)
	
func init_hud():
	#reset score texts
	reset_score_ui()
	#reset score announcement
	reset_score_announce()

func announce_score(player_id: int):
	score_announce.get_parent().get_parent().show()
	score_announce.text = "Player " + str(player_id) + " Scored!"

func reset_score_announce():
	score_announce.get_parent().get_parent().hide()
	score_announce.text = "Scored!"

func reset_score_ui():
	for player in player_count:
		player_scores_container.get_child(player).show()
		player_scores.get(player).text = str(0)
