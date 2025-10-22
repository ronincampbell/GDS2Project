extends RigidBody3D

@export var move_force: float = 30.0
@export var max_speed: float = 10.0
@export var device_id: int = 0

var _move_input := Vector3.ZERO
var _caster: Node = null

func _ready() -> void:
	can_sleep = false
	_caster = get_node_or_null("SpellCaster")
	if _caster:
		_caster.attach(self, device_id)

func _physics_process(delta: float) -> void:
	_move_input = Vector3.ZERO
	if Input.is_action_pressed("PlayerUp"):  _move_input.z -= 1.0
	if Input.is_action_pressed("PlayerDown"):     _move_input.z += 1.0
	if Input.is_action_pressed("PlayerLeft"):     _move_input.x -= 1.0
	if Input.is_action_pressed("PlayerRight"):    _move_input.x += 1.0
	if _move_input.length() > 1.0:
		_move_input = _move_input.normalized()

	if _move_input != Vector3.ZERO:
		apply_central_force(_move_input * move_force)

	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed

func apply_knockback(from: Vector3, strength: float) -> void:
	var s := strength
	if _caster and _caster.has_method("filter_knockback"):
		s = _caster.filter_knockback(s)

	var dir := (global_position - from).normalized()
	apply_central_impulse(dir * s)
