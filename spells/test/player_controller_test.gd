extends CharacterBody3D
class_name PlayerController

@export var move_speed: float = 7.0
@export var turn_speed_deg: float = 180.0
@export var gravity: float = 24.0

# optional: where to respawn with R
@export var respawn_position: Vector3 = Vector3(-6, 1, 0)
@export var respawn_facing_deg: float = 0.0

var _kb: Vector3 = Vector3.ZERO  # knockback buffer (compatible with the old dummy behavior)
var _caster: SpellCaster
@onready var _muzzle: Node3D = get_node_or_null("Muzzle")

func _ready() -> void:
	_caster = get_node_or_null("SpellCaster") as SpellCaster
	if _caster == null:
		push_error("PlayerController: missing child node 'SpellCaster' with SpellCaster.gd")
	# place at start if desired
	if respawn_position != Vector3.ZERO:
		global_position = respawn_position
	rotation.y = deg_to_rad(respawn_facing_deg)

func _physics_process(delta: float) -> void:
	# --- turn (A/D) ---
	var yaw_input := 0.0
	if Input.is_key_pressed(KEY_A): yaw_input -= 1.0
	if Input.is_key_pressed(KEY_D): yaw_input += 1.0
	rotation.y += deg_to_rad(turn_speed_deg) * yaw_input * delta

	# --- move (W/S) in local forward plane ---
	var move_input := 0.0
	if Input.is_key_pressed(KEY_W): move_input += 1.0
	if Input.is_key_pressed(KEY_S): move_input -= 1.0

	var forward: Vector3 = -global_transform.basis.z
	var wish: Vector3 = forward * move_input * move_speed
	# carry over any knockback the spells applied
	var horiz := Vector3(wish.x + _kb.x, 0.0, wish.z + _kb.z)

	velocity.x = horiz.x
	velocity.z = horiz.z

	# gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()

	# decay knockback smoothly
	_kb = _kb.move_toward(Vector3.ZERO, 10.0 * delta)

	# cast on Space (single-slot "use whatever I have")
	if Input.is_key_pressed(KEY_SPACE) and _caster != null:
		_caster.cast_current()

	# quick reset to start with R
	if Input.is_key_pressed(KEY_R):
		_reset_to_spawn()

func apply_knockback(from: Vector3, strength: float) -> void:
	var dir := (global_transform.origin - from).normalized()
	_kb += dir * strength

func _reset_to_spawn() -> void:
	global_position = respawn_position
	velocity = Vector3.ZERO
	_kb = Vector3.ZERO
	rotation.y = deg_to_rad(respawn_facing_deg)
