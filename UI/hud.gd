extends Control

@onready var score = $PanelContainer/MarginContainer/RichTextLabel

func update_score(new_score: int):
	score.text = "Score: " + str(new_score)
