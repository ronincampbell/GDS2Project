extends Node

@onready var gameplay_music = $Gameplay
@onready var lobby_music = $Lobby

func _ready() -> void:
	gameplay_music.finished.connect(_on_music_finished)
	lobby_music.finished.connect(_on_lobby_finished)

func play_gameplay_music(volume_db: float = 0.0):
	gameplay_music.volume_db = volume_db
	gameplay_music.play()

func stop_gameplay_music():
	gameplay_music.stop()

func play_lobby_music(volume_db: float = 0.0):
	lobby_music.volume_db = volume_db
	lobby_music.play()

func stop_lobby_music():
	lobby_music.stop()

func _on_music_finished():
	gameplay_music.play()

func _on_lobby_finished():
	lobby_music.play()
