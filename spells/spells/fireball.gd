extends RigidBody3D
class_name Fireball

@export var speed: float = 24.0
@export var strength: float = 25.0
@export var splash_radius: float = 8.0
@export var lifetime: float = 2.5
@export var hit_radius: float = 0.2
@export var ignore_self_time: float = 0.5
@export var debug_mode: bool = true
@export var arm_time: float = 0.5
@export_flags_3d_physics var hit_mask: int = 0xFFFFFFFF

var shooter: Node = null
var _age := 0.0
var _prev_pos: Vector3
var _last_dir: Vector3 = Vector3.FORWARD

func _ready() -> void:
	gravity_scale = 0.0
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true

	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)

	collision_layer = 0
	set_collision_layer_value(1, true)
	collision_mask = 0xFFFFFFFF

	if shooter and shooter is PhysicsBody3D:
		add_collision_exception_with(shooter)

	var dir := -global_transform.basis.z
	linear_velocity = dir * speed
	sleeping = false

	_prev_pos = global_position - dir * 0.2

func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		_explode_and_free(global_position)
		return

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var from := _prev_pos
	var to := global_position
	var move := to - from
	if move.length() > 0.0001:
		_last_dir = move.normalized()

	var space := get_world_3d().direct_space_state
	var rq := PhysicsRayQueryParameters3D.create(from, to)
	rq.exclude = [self, shooter]
	rq.collide_with_areas = true
	rq.collide_with_bodies = true
	rq.collision_mask = hit_mask
	rq.hit_from_inside = true

	var hit := space.intersect_ray(rq)
	if hit.has("collider"):
		if _age < arm_time:
			_prev_pos = to
			return
		var p: Vector3 = hit.get("position", to)
		var n: Vector3 = hit.get("normal", _last_dir)
		_explode_and_free(p, n)
		return

	var nose := SphereShape3D.new()
	nose.radius = hit_radius
	var sq := PhysicsShapeQueryParameters3D.new()
	sq.shape = nose
	sq.transform = Transform3D(Basis(), to)
	sq.exclude = [self, shooter]
	sq.collide_with_areas = true
	sq.collide_with_bodies = true
	sq.collision_mask = hit_mask

	var overlaps := space.intersect_shape(sq, 8)
	if overlaps.size() > 0:
		if _age < arm_time:
			_prev_pos = to
			return
		_explode_and_free(to, _last_dir)
		return
	_prev_pos = to

func _on_body_entered(body: Node) -> void:
	if _age < arm_time:
		return
	if body is Node and body.is_in_group("shielded"):
		return
	_explode_and_free(global_position)

func _explode_and_free(at: Vector3, outward: Vector3 = Vector3.ZERO) -> void:
	if splash_radius <= 0.0:
		queue_free()
		return

	if outward != Vector3.ZERO:
		at += outward.normalized() * 0.30

	var sphere := SphereShape3D.new()
	sphere.radius = splash_radius
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = sphere
	q.transform = Transform3D(Basis(), at)
	q.exclude = [self]
	q.collide_with_areas = true
	q.collide_with_bodies = true
	q.collision_mask = hit_mask

	var hits := get_world_3d().direct_space_state.intersect_shape(q, 128)
	var rigid_count := 0
	var listed := 0

	for h in hits:
		var obj: Object = h.get("collider")
		if obj == null:
			continue

		if obj == shooter and _age <= ignore_self_time:
			continue
		var node := obj as Node

		if node != null and node.is_in_group("shielded"):
			continue
		var body := obj as RigidBody3D

		if body != null:
			rigid_count += 1
			if body.freeze:
				body.freeze = false
			body.sleeping = false
			var delta := body.global_transform.origin - at
			var dist  : float = max(0.001, delta.length())
			var dir := _last_dir
			if dist > 0.0001:
				dir = delta / dist
			var falloff : float = clamp(1.0 - (dist / splash_radius), 0.0, 1.0)
			var mass    : float = max(0.01, body.mass)
			var impulse := dir * strength * falloff * mass
			body.apply_central_impulse(impulse)
			body.linear_velocity += dir * (strength * falloff * 1.25)

	if rigid_count == 0:
		var pushed := 0
		for n in get_tree().get_nodes_in_group("pushable"):
			if not (n is RigidBody3D):
				continue
			var body2 := n as RigidBody3D
			if body2 == shooter and _age <= ignore_self_time:
				continue

			var delta2 := body2.global_transform.origin - at
			var dist2 := delta2.length()
			if dist2 > splash_radius:
				continue

			if body2.freeze:
				body2.freeze = false
			body2.sleeping = false

			var dir2 := _last_dir
			if dist2 > 0.0001:
				dir2 = delta2 / dist2

			var falloff2 : Variant = clamp(1.0 - (dist2 / splash_radius), 0.0, 1.0)
			var mass2    : float = max(0.01, body2.mass)
			var impulse2 : Variant = dir2 * strength * falloff2 * mass2
			body2.apply_central_impulse(impulse2)
			body2.linear_velocity += dir2 * (strength * falloff2 * 1.25)
			pushed += 1

	queue_free()

func _dbg(msg: String) -> void:
	if debug_mode:
		print_debug("Fireball: ", msg, " age=", _age, " pos=", global_position)
