extends Area3D
class_name Shield

@export var duration: float = 5.0
@export var radius: float = 1.2
@export var absorb_knockback_scale: float = 0.2
@export var sfx_cast: AudioStream
@export var sfx_expire: AudioStream
@export var sfx_bus: StringName = &"SFX"
@export var sfx_pitch_jitter: float = 0.05
@export var sfx_volume_db: float = 0.0

var owner_player: PhysicsBody3D = null
var owner_caster: SpellCaster

var _elapsed: float = 0.0
@onready var _shape: CollisionShape3D = $CollisionShape3D
@onready var _visual: MeshInstance3D = get_node_or_null("Visual")

func _ready() -> void:
	var sphere: SphereShape3D
	if _shape.shape is SphereShape3D:
		sphere = _shape.shape as SphereShape3D
	else:
		sphere = SphereShape3D.new()
		_shape.shape = sphere
	sphere.radius = radius

	if owner_player != null:
		global_position = owner_player.global_position

	if owner_caster != null:
		owner_caster._on_shield_started(absorb_knockback_scale)

	if _visual != null:
		var s: float = radius * 2.0
		_visual.scale = Vector3(s, s, s)

	body_entered.connect(_on_body_entered)
	set_physics_process(true)

	if owner_player != null:
		owner_player.set("is_shielded", true)
		owner_player.set("shield_absorb_scale", absorb_knockback_scale)
		owner_player.add_to_group("shielded")
		_play_sfx_3d(sfx_cast, global_position)

func _physics_process(delta: float) -> void:
	_elapsed += delta

	if owner_player != null:
		global_position = owner_player.global_position

	if _elapsed >= duration or owner_player == null:
		_cleanup_and_free()

func _on_body_entered(b: Node) -> void:
	if b is Fireball:
		var fb := b as Fireball
		fb.destroy_on_world_hit = false
		fb.queue_free()

func _cleanup_and_free() -> void:
	if owner_caster != null:
		owner_caster._on_shield_ended()
	if owner_player and owner_player.is_in_group("shielded"):
		owner_player.remove_from_group("shielded")
	_play_sfx_3d(sfx_expire, global_position)
	queue_free()

func _play_sfx_3d(stream: AudioStream, at_pos: Vector3) -> void:
	if stream == null:
		return
	var p := AudioStreamPlayer3D.new()
	p.stream = stream
	p.bus = sfx_bus
	p.volume_db = sfx_volume_db
	p.pitch_scale = randf_range(1.0 - sfx_pitch_jitter, 1.0 + sfx_pitch_jitter)
	p.global_transform = Transform3D(Basis(), at_pos)
	p.max_distance = 80.0
	p.unit_size = 1.0

	var host := get_tree().current_scene
	if host == null:
		host = get_tree().root
	host.add_child(p)
	p.finished.connect(Callable(p, "queue_free"))
	p.play()
