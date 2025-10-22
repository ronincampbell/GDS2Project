extends Node3D

@export var fireball_scene: PackedScene
@export var rate_hz: float = 1
@export var auto_start: bool = true
@export var use_muzzle_forward: bool = true
@export var spawn_offset: float = 1.2

@onready var muzzle: Node3D = $Muzzle if has_node("Muzzle") else null

var _accum := 0.0
var _interval := 1.0

func _ready() -> void:
	_interval = 1.0 / max(rate_hz, 0.01)
	set_process(auto_start)

func start() -> void: set_process(true)
func stop() -> void: set_process(false)

func _process(delta: float) -> void:
	_accum += delta
	while _accum >= _interval:
		_accum -= _interval
		_fire_once()

func _fire_once() -> void:
	if fireball_scene == null:
		push_error("FireballEmitter: fireball_scene not set.")
		return

	var fb := fireball_scene.instantiate()
	if fb == null:
		return

	var origin: Node3D = (muzzle if use_muzzle_forward and muzzle != null else self)
	var dir: Vector3 = -origin.global_transform.basis.z.normalized()

	if fb is Node3D:
		fb.global_transform = origin.global_transform
		fb.global_position = origin.global_position + dir * spawn_offset
		(fb as Node3D).look_at(fb.global_position + dir, Vector3.UP)

	if "shooter" in fb:
		fb.shooter = null

	get_tree().current_scene.add_child(fb)
