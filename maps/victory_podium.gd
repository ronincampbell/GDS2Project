extends Node3D

func _ready():
	get_node("%PhysicsP" + str(VictoryHoldover.last_winner)).freeze = false
	$Hud/Label.text = "Player "+str(VictoryHoldover.last_winner)+" wins!"
	$GnomeLaugh.play()
	var wait_tween = create_tween()
	wait_tween.tween_interval(3.0)
	wait_tween.tween_callback(return_to_lobby)

func return_to_lobby():
	ControllerManager.reset_players()
	get_tree().change_scene_to_file("res://maps/lobby.tscn")
