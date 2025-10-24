extends Node3D

@onready var winner_text = $VictoryHud/WinnerTextPanel/MarginContainer/PanelContainer/AnnounceMargin/WinnerText

func _ready():
	get_node("%PhysicsP" + str(VictoryHoldover.last_winner)).freeze = false
	winner_text.text = "Player "+str(VictoryHoldover.last_winner)+" wins!"
	$GnomeLaugh.play()
	Hud.show_scoreboard()
	var wait_tween = create_tween()
	wait_tween.tween_interval(5.0)
	wait_tween.tween_callback(return_to_lobby)

func return_to_lobby():
	ControllerManager.reset_players()
	get_tree().change_scene_to_file("res://maps/lobby.tscn")
