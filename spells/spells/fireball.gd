extends RigidBody3D
class_name Fireball

@export var speed: float = 10.0
@export var strength: float = 150.0
@export var lifetime: float = 2.5
@export var splash_radius: float = 5.0
@export var destroy_on_world_hit: bool = true
@export var hit_radius: float = 0.18

var shooter: Node = null
var _age: float = 0.0

func _ready() -> void:
	gravity_scale = 0.0
	continuous_cd = true
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true

	contact_monitor = true
	max_contacts_reported = 8

	collision_layer = 1
	collision_mask = 0
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_mask_value(3, true)

	linear_velocity = -global_transform.basis.z * speed
	sleeping = false

func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		_explode_and_free(global_transform.origin)
		return

	var from: Vector3 = global_transform.origin
	var to: Vector3 = from + linear_velocity * delta

	var params := PhysicsRayQueryParameters3D.create(from, to)
	params.exclude = [self, shooter]
	params.collision_mask = collision_mask
	params.collide_with_areas = true
	params.hit_from_inside = true

	var hit := get_world_3d().direct_space_state.intersect_ray(params)
	if hit.has("collider"):
		_on_hit(hit["collider"], hit.get("position", to))
		return

	var ol := _overlap_any(from)
	if ol.collider != null:
		_on_hit(ol.collider, ol.position)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var count: int = state.get_contact_count()
	for i in range(count):
		var collider := state.get_contact_collider_object(i)
		if collider != null:
			var local_pos := state.get_contact_local_position(i)
			var global_pos := global_transform * local_pos
			_on_hit(collider, global_pos)
			break

func _overlap_any(at: Vector3) -> Dictionary:
	var shape := SphereShape3D.new()
	shape.radius = hit_radius
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = shape
	q.transform = Transform3D(Basis(), at)
	q.exclude = [self, shooter]
	q.collide_with_bodies = true
	q.collide_with_areas = true
	q.collision_mask = collision_mask
	var hits := get_world_3d().direct_space_state.intersect_shape(q, 8)
	if hits.size() > 0:
		var h := hits[0]
		return {"collider": h.get("collider"), "position": at}
	return {"collider": null, "position": at}

func _on_hit(other: Object, hit_pos: Vector3) -> void:
	if shooter != null and other == shooter:
		return
	_explode_and_free(hit_pos)

func explode(at: Vector3) -> void:
	_explode_and_free(at)

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
	q.exclude = [self]
	q.collide_with_bodies = true
	q.collide_with_areas = true
	q.collision_mask = 0x7FFFFFFF

	var hits: Array = space.intersect_shape(q, 64)
	for h in hits:
		var b: Object = h.get("collider")
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
			if (b as CharacterBody3D).has_method("apply_knockback"):
				(b as CharacterBody3D).apply_knockback(at, strength)

	queue_free()
