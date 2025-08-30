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

func _ready() -> void:
	init_score_texts()

func update_score(player_id: int, new_score: int):
	player_scores.get(player_id).text = str(new_score)
	
func init_score_texts():
	for player in player_count:
		player_scores_container.get_child(player).show()
		player_scores.get(player).text = str(0)
