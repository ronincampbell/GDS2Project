extends Node

@onready var ball_in_hole: AudioStreamPlayer = $BallInHole

func play_ball_in_hole():
	ball_in_hole.play()
