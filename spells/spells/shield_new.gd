extends Node3D

@export var duration: float = 4.0

var parent_body: Node = null

func _ready() -> void:
	parent_body = get_parent()
	if parent_body != null:
		parent_body.set("is_shielded", true)
	_fade_out_later()

func _exit_tree() -> void:
	if parent_body != null and parent_body.has_variable("is_shielded"):
		parent_body.set("is_shielded", false)

func _fade_out_later() -> void:
	await get_tree().create_timer(duration).timeout
	if parent_body != null and parent_body.has_variable("is_shielded"):
		parent_body.set("is_shielded", false)
	queue_free()
