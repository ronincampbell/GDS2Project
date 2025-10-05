extends Node
class_name KnockbackHelper
# A helper to apply knockback

static func radial_push(body: Node, center: Vector3, radius: float, strength: float, up_boost: float = 0.0) -> void:
	if !(body is RigidBody3D) and !(body is CharacterBody3D):
		return

	var dir: Vector3 = (body.global_position - center)
	dir.y = 0.25
	var dist: float = max(dir.length(), 0.001)
	dir = dir / dist
	var falloff: float = clamp(1.0 - (dist / radius), 0.0, 1.0)
	var impulse: Vector3 = dir * (strength * falloff) + Vector3.UP * up_boost * falloff

	if body is RigidBody3D:
		(body as RigidBody3D).apply_central_impulse(impulse)
	elif body is CharacterBody3D:
		var c := body as CharacterBody3D
		c.velocity += impulse * 0.75
