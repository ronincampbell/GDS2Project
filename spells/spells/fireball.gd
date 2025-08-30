extends RigidBody3D
class_name Fireball

@export var speed: float = 10.0
@export var strength: float = 5.0
@export var lifetime: float = 2.5
@export var splash_radius: float = 0.0
@export var destroy_on_world_hit: bool = true

var shooter: Node = null
var _age: float = 0.0

func _ready() -> void:
	linear_velocity = -global_transform.basis.z * speed

func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		_explode_and_free(global_transform.origin)

	var from: Vector3 = global_transform.origin
	var to: Vector3 = from + linear_velocity * delta

	var params := PhysicsRayQueryParameters3D.create(from, to)
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(params)
	if hit.size() > 0 and hit.has("collider"):
		var collider: Object = hit["collider"]
		var pos: Vector3 = Vector3(hit["position"]) if hit.has("position") else from
		_on_hit(collider, pos)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var count: int = state.get_contact_count()
	for i in range(count):
		var collider: Object = state.get_contact_collider_object(i)
		if collider != null:
			var pos: Vector3 = state.get_contact_local_position(i)
			_on_hit(collider, pos)
			break

func _on_hit(other: Object, hit_pos: Vector3) -> void:
	if shooter != null and other == shooter:
		return

	if other is CharacterBody3D:
		var target := other as CharacterBody3D
		if target.has_method("apply_knockback"):
			target.apply_knockback(global_transform.origin, strength)
		_explode_and_free(hit_pos)
		return

	if other is RigidBody3D:
		var rb := other as RigidBody3D
		var dir: Vector3 = (rb.global_transform.origin - global_transform.origin).normalized()
		rb.apply_central_impulse(dir * strength)
		_explode_and_free(hit_pos)
		return

	if destroy_on_world_hit and other is Node:
		_explode_and_free(hit_pos)

func _explode_and_free(at: Vector3) -> void:
	if splash_radius > 0.0:
		var space := get_world_3d().direct_space_state
		var shape := SphereShape3D.new()
		shape.radius = splash_radius
		var q := PhysicsShapeQueryParameters3D.new()
		q.shape = shape
		q.transform = Transform3D(Basis(), at)
		q.collide_with_bodies = true

		var hits: Array = space.intersect_shape(q, 16)
		for hit_dict in hits:
			var b: Object = hit_dict.get("collider")
			if b == shooter: 
				continue
			if b is CharacterBody3D:
				var target := b as CharacterBody3D
				if target.has_method("apply_knockback"):
					target.apply_knockback(at, strength * 0.7)
			elif b is RigidBody3D:
				var rb := b as RigidBody3D
				var dir: Vector3 = (rb.global_transform.origin - at).normalized()
				rb.apply_central_impulse(dir * strength * 0.7)
	queue_free()
