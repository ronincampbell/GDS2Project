extends RigidBody3D
class_name Fireball

@export var speed: float = 24.0              # a bit faster for snappier feel
@export var strength: float = 200.0           # base impulse strength (we also mass-scale below)
@export var splash_radius: float = 12.0       # tune to taste
@export var lifetime: float = 2.5
@export var hit_radius: float = 0.2          # tiny nose sphere for overlap hits
@export var ignore_self_time: float = 0.5   # seconds to ignore shooter
@export var debug_mode: bool = true
@export var arm_time: float = 0.5
@export_flags_3d_physics var hit_mask: int = 0xFFFFFFFF

var shooter: Node = null

var _age := 0.0
var _prev_pos: Vector3

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
		_explode_and_free(p)
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
		_explode_and_free(to)
		return
	_prev_pos = to

func _on_body_entered(body: Node) -> void:
	if _age < arm_time:
		return
	if body is Node and body.is_in_group("shielded"):
		return
	_explode_and_free(global_position)

func _explode_and_free(at: Vector3) -> void:
	if splash_radius <= 0.0:
		queue_free()
		return

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
	_dbg("EXP hits=" + str(hits.size()))

	var rigid_count := 0
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
			var pre_mode : Variant = body.mode
			var pre_sleep := body.sleeping
			var pre_freeze := body.freeze
			var pre_mass := body.mass
			var pre_ld := body.linear_damp

			# If it's frozen or sleeping, wake/unfreeze it so impulses actually apply
			if body.freeze:
				body.freeze = false
			body.sleeping = false
			# (Optional) if a character/kinematic slipped in, make it rigid for the shove
			# Comment out if you don't want to touch modes:
			# if body.mode != RigidBody3D.MODE_RIGID:
			#     body.mode = RigidBody3D.MODE_RIGID

			var delta := body.global_transform.origin - at
			var dist  : float = max(0.001, delta.length())
			var dir   := delta / dist
			var falloff : float = clamp(1.0 - (dist / splash_radius), 0.0, 1.0)

			# Impulse scaled by mass (physically "correct")
			var impulse : Variant = dir * strength * falloff * max(0.01, pre_mass)
			body.apply_central_impulse(impulse)

			# Extra visible kick to overpower scripts that zero velocity each tick
			# (tune 1.0..2.0 or remove later once you're confident)
			body.linear_velocity += dir * (strength * falloff * 1.25)

			_dbg("PUSH -> %s mode=%d sleep=%s freeze=%s mass=%.2f ld=%.2f falloff=%.2f"
				% [body.name, pre_mode, str(pre_sleep), str(pre_freeze), pre_mass, pre_ld, falloff])
	_dbg("EXP rigid_count=" + str(rigid_count) + " of " + str(hits.size()))

	queue_free()

func _dbg(msg: String) -> void:
	if debug_mode:
		print_debug("Fireball: ", msg, " age=", _age, " pos=", global_position)
