extends Control

@onready var names_container = $PanelContainer/MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer/PlayerNamesContainer
@onready var scores_container = $PanelContainer/MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer2/PlayerScoresContainer

var name_and_scores = []

func _ready() -> void:
	for player in names_container.get_children():
		name_and_scores.push_back([player, scores_container.get_child(player.get_index())])
	#set_scoreboard()

func set_scoreboard():
	#needs player dict
	#for player in name_and_scores:
		#player.get(0).text = "" 
		#player.get(1).text = "" 
	name_and_scores.sort_custom(sort_descending)
	sort_scoreboard()

func sort_scoreboard():
	var rank
	for player in name_and_scores:
		rank = name_and_scores.find(player)
		names_container.move_child(player.get(0), rank)
		scores_container.move_child(player.get(1), rank)

func sort_descending(a, b):
	if int(a[1].text) > int(b[1].text):
		return true
	return false
