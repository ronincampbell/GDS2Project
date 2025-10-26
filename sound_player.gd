extends Node

@onready var ball_in_hole: AudioStreamPlayer = $BallInHole

const cast_fireball = preload("res://sounds/cast_fireball.wav")
const explosion = preload("res://sounds/explosion.wav")
const cast_shield = preload("res://sounds/cast_shield.wav")
const shield_off = preload("res://sounds/shield_off.wav")

func play_ball_in_hole():
	ball_in_hole.play()
	await get_tree().create_timer(0.25).timeout
	$Score.play()

func play_fireball_effect(is_casting: bool = true):
	if is_casting:
		$Fireball.stream = cast_fireball
		$Fireball.play()
	else:
		$Fireball.stream = explosion
		$Fireball.play()

func play_shield_effect(is_shield_on: bool = true):
	if is_shield_on:
		$Shield.stream = cast_shield
		$Shield.play()
	else:
		$Shield.stream = shield_off
		$Shield.play()

func play_spell_pickup():
	$Spell.play()
