extends RigidBody3D
class_name Fireball

@export var speed: float = 10.0
@export var strength: float = 5.0
@export var lifetime: float = 2.5
@export var splash_radius: float = 3.0
@export var destroy_on_world_hit: bool = true

var shooter: Node = null
var _age: float = 0.0

func _ready() -> void:
	linear_velocity = -global_transform.basis.z * speed

func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		_explode_and_free(global_transform.origin)
		return

	var from: Vector3 = global_transform.origin
	var to: Vector3 = from + linear_velocity * delta

	var params := PhysicsRayQueryParameters3D.create(from, to)
	params.exclude = [self, shooter]
	params.collide_with_areas = true
	params.hit_from_inside = true
	var hit := get_world_3d().direct_space_state.intersect_ray(params)
	if hit.size() > 0 and hit.has("collider"):
		var collider: Object = hit["collider"]
		var pos: Vector3 = hit.get("position", to)
		_on_hit(collider, pos)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var count: int = state.get_contact_count()
	for i in range(count):
		var collider: Object = state.get_contact_collider_object(i)
		if collider != null:
			var local_pos: Vector3 = state.get_contact_local_position(i)
			var global_pos: Vector3 = global_transform * local_pos
			_on_hit(collider, global_pos)
			break

func _on_hit(other: Object, hit_pos: Vector3) -> void:
	if shooter != null and other == shooter:
		return
	_explode_and_free(hit_pos)

func _explode_and_free(at: Vector3) -> void:
	if splash_radius <= 0.0:
		queue_free()
		return

	var space := get_world_3d().direct_space_state
	var shape := SphereShape3D.new()
	shape.radius = splash_radius

	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = shape
	q.transform = Transform3D(Basis(), at)
	q.collide_with_bodies = true
	q.exclude = [self]

	var hits: Array = space.intersect_shape(q, 64)
	for hit_dict in hits:
		var b: Object = hit_dict.get("collider")
		if b == shooter:
			continue

		var node := b as Node
		if node != null and node.is_in_group("shielded"):
			continue

		if b is RigidBody3D:
			var rb := b as RigidBody3D
			var to_b: Vector3 = rb.global_transform.origin - at
			var dist: float = max(0.001, to_b.length())
			var dir: Vector3 = to_b / dist
			var falloff: float = clamp(1.0 - (dist / splash_radius), 0.0, 1.0)
			rb.apply_central_impulse(dir * strength * falloff)
		elif b is CharacterBody3D:
			var target := b as CharacterBody3D
			if target.has_method("apply_knockback"):
				target.apply_knockback(at, strength)

	queue_free()
