extends Area3D
class_name Shield

@export var duration: float = 5.0
@export var radius: float = 1.2
@export var reflect_projectiles: bool = true
@export var absorb_knockback_scale: float = 0.2

var owner_player: CharacterBody3D = null

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

	if _visual != null:
		var s: float = radius * 2.0
		_visual.scale = Vector3(s, s, s)

	body_entered.connect(_on_body_entered)
	set_physics_process(true)

	if owner_player != null:
		owner_player.set("is_shielded", true)
		owner_player.set("shield_absorb_scale", absorb_knockback_scale)

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
	if owner_player != null:
		if owner_player.has_variable("is_shielded"):
			owner_player.is_shielded = false
		if owner_player.has_variable("shield_absorb_scale"):
			owner_player.shield_absorb_scale = 1.0
	queue_free()
