extends RigidBody3D
class_name PlayerController

@export var move_speed: float = 7.0
@export var turn_speed_deg: float = 180.0
@export var gravity: float = 10.0
@export var device_id: int = 0

var _kb: Vector3 = Vector3.ZERO
var _caster: SpellCaster

func _ready() -> void:
	custom_integrator = true
	gravity_scale = 0.0
	_caster = get_node_or_null("SpellCaster") as SpellCaster
	if _caster:
		_caster.attach(self, device_id)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var yaw := 0.0
	if Input.is_action_pressed("turn_left"):  yaw -= 1.0
	if Input.is_action_pressed("turn_right"): yaw += 1.0
	var xf := state.transform
	xf.basis = Basis(Vector3.UP, deg_to_rad(turn_speed_deg) * yaw * state.step) * xf.basis

	var flat := Input.get_vector("PlayerLeft","PlayerRight","PlayerUp","PlayerDown", 0.2)
	var forward := -xf.basis.z
	var right   :=  xf.basis.x
	var wish := (right * flat.x + forward * flat.y) * move_speed

	var vel := wish + Vector3(_kb.x, 0.0, _kb.z)
	if gravity != 0.0:
		vel.y -= gravity * state.step

	xf.origin += vel * state.step
	state.transform = xf

	_kb = _kb.move_toward(Vector3.ZERO, 10.0 * state.step)

func apply_knockback(from: Vector3, strength: float) -> void:
	var dir := (global_transform.origin - from).normalized()
	_kb += dir * strength
