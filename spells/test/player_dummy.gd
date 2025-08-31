extends CharacterBody3D
class_name PlayerDummy

@export var knockback_decay: float = 10.0
var kb: Vector3 = Vector3.ZERO

func _ready() -> void:
	var muzzle := get_node_or_null("Muzzle") as Node3D
	if muzzle != null and muzzle.transform.origin == Vector3.ZERO:
		muzzle.transform.origin = Vector3(0, 1.4, -0.6)

func _physics_process(delta: float) -> void:
	velocity.x = kb.x
	velocity.z = kb.z
	if not is_on_floor():
		velocity.y -= 24.0 * delta
	move_and_slide()
	kb = kb.move_toward(Vector3.ZERO, knockback_decay * delta)

func apply_knockback(from: Vector3, strength: float) -> void:
	var dir: Vector3 = (global_transform.origin - from).normalized()
	kb += dir * strength
