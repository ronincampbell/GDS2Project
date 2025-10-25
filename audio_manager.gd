extends Node

@onready var music_source = $Music
var loop_music: bool = false

func _ready() -> void:
	music_source.finished.connect(_on_music_finished)

func play_gameplay_music(volume_db: float = 0.0, loop: bool = true):
	music_source.volume_db = volume_db
	music_source.play()
	loop_music = loop

func stop_gameplay_music():
	music_source.stop()

func _on_music_finished():
	if loop_music:
		music_source.play()
