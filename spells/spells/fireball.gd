extends RigidBody3D
class_name Fireball

@export var explosion_radius: float = 4.0
@export var explosion_strength: float = 18.0
@export var explosion_up_boost: float = 4.0 # Optional
@export var max_lifetime: float = 3.0

var life: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	life += delta
	if life > max_lifetime:
		_explode()

func _on_body_entered(_other: Node) -> void:
	_explode()

func _explode() -> void:
	if !is_inside_tree():
		return
	var center := global_transform.origin
	var params: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	var sphere: SphereShape3D = SphereShape3D.new()
	sphere.radius = explosion_radius
	params.shape = sphere
	params.transform = Transform3D(Basis.IDENTITY, center)
	params.collide_with_areas = false
	params.collide_with_bodies = true
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var results: Array = space_state.intersect_shape(params, 64)
	for hit in results:
		var n : Variant = hit.get("collider")
		if n == self:
			continue
		if _has_shield(n):
			continue
		KnockbackHelper.radial_push(n, center, explosion_radius, explosion_strength, explosion_up_boost)
	# Add sounds and particles here
	queue_free()

func _has_shield(n: Node) -> bool:
	var cur: Node = n
	for i in 4:
		if cur == null:
			return false
		if cur.has_variable("is_shielded") and cur.is_shielded == true:
			return true
		cur = cur.get_parent()
	return false

#@export var speed: float = 24.0              # a bit faster for snappier feel
#@export var strength: float = 50.0           # base impulse strength (we also mass-scale below)
#@export var splash_radius: float = 4.0       # tune to taste
#@export var lifetime: float = 2.5
#@export var hit_radius: float = 0.2          # tiny nose sphere for overlap hits
#@export var ignore_self_time: float = 0.10   # seconds to ignore shooter
#@export var debug_mode: bool = false
#
#var shooter: Node = null
#
#var _age := 0.0
#var _prev_pos: Vector3
#
#func _ready() -> void:
	#gravity_scale = 0.0
	#axis_lock_angular_x = true
	#axis_lock_angular_y = true
	#axis_lock_angular_z = true
#
	#contact_monitor = true
	#max_contacts_reported = 8
#
	#collision_layer = 0
	#set_collision_layer_value(6, true)
	#collision_mask = 0
	#for i in range(1,9):
		#set_collision_mask_value(i, true)
#
	#if shooter and shooter is PhysicsBody3D:
		#add_collision_exception_with(shooter)
#
	#var dir := -global_transform.basis.z
	#linear_velocity = dir * speed
	#sleeping = false
#
	#_prev_pos = global_position - dir * 0.2
#
#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#_age += state.step
	#if _age >= lifetime:
		#_explode_and_free(global_position)
		#return
#
	#var from := _prev_pos
	#var to := global_position
#
	#var space := get_world_3d().direct_space_state
	#var rq := PhysicsRayQueryParameters3D.create(from, to)
	#rq.exclude = [self, shooter]
	#rq.collide_with_areas = true
	#rq.collide_with_bodies = true
	#rq.collision_mask = collision_mask
	#rq.hit_from_inside = true
#
	#var hit := space.intersect_ray(rq)
	#if hit.has("collider"):
		#var did_hit_self : bool = (shooter != null and hit.get("collider") == shooter)
		#if not did_hit_self or _age > ignore_self_time:
			#var p: Vector3 = hit.get("position", to)
			#_explode_and_free(p)
			#return
#
	#var nose := SphereShape3D.new()
	#nose.radius = hit_radius
	#var sq := PhysicsShapeQueryParameters3D.new()
	#sq.shape = nose
	#sq.transform = Transform3D(Basis(), to)
	#sq.exclude = [self, shooter]
	#sq.collide_with_areas = true
	#sq.collide_with_bodies = true
	#sq.collision_mask = collision_mask
#
	#var overlaps := space.intersect_shape(sq, 8)
	#if overlaps.size() > 0:
		#var found := false
		#for o in overlaps:
			#var col : Variant = o.get("collider")
			#if col == shooter and _age <= ignore_self_time:
				#continue
			#found = true
			#break
		#if found:
			#_explode_and_free(to)
			#return
#
	#_prev_pos = to
#
#func _explode_and_free(at: Vector3) -> void:
	#if splash_radius <= 0.0:
		#queue_free()
		#return
#
	#var sphere := SphereShape3D.new()
	#sphere.radius = splash_radius
	#var q := PhysicsShapeQueryParameters3D.new()
	#q.shape = sphere
	#q.transform = Transform3D(Basis(), at)
	#q.exclude = [self]
	#q.collide_with_areas = true
	#q.collide_with_bodies = true
	#q.collision_mask = 0x7FFFFFFF
#
	#var hits := get_world_3d().direct_space_state.intersect_shape(q, 128)
#
	#for h in hits:
		#var obj: Object = h.get("collider")
		#if obj == null:
			#continue
		#if obj == shooter and _age <= ignore_self_time:
			#continue
#
		#var node := obj as Node
		#if node != null and node.is_in_group("shielded"):
			#continue
#
		#var body := obj as RigidBody3D
		#if body != null:
			#var delta := body.global_transform.origin - at
			#var dist : float = max(0.001, delta.length())
			#var dir := delta / dist
#
			#var falloff : float = clamp(1.0 - (dist / splash_radius), 0.0, 1.0)
#
			#var mass : float = max(0.01, body.mass)
			#var impulse := dir * strength * falloff * mass
			#body.apply_central_impulse(impulse)
#
		##optional CharacterBody3D adapter
		#var cbody := obj as CharacterBody3D
		#if cbody != null and cbody.has_method("apply_knockback"):
			#cbody.apply_knockback(at, strength)
#
	#queue_free()
#
#func _dbg(msg: String) -> void:
	#if debug_mode:
		#print_debug("Fireball: ", msg, " age=", _age, " pos=", global_position)
