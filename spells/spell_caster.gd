extends Node
class_name SpellCaster

enum SpellID { FIREBALL, SHIELD }

var current_spell: int = -1

@export var fireball_scene: PackedScene
@export var shield_scene: PackedScene
@export var cast_action: StringName = &"CastSpell"

var _device_id: int = 0
var _player: Node3D
#var _player: CharacterBody3D
@onready var _muzzle: Node3D = get_parent().get_node_or_null("Muzzle")

var shield_active := false
var shield_absorb_scale := 0.9

func attach(player: Node3D, device_id: int) -> void:
	_player = player
	_device_id = device_id

func has_spell() -> bool:
	return current_spell != -1

func give_spell(id: int) -> bool:
	if has_spell():
		return false
	current_spell = id
	return true

func _unhandled_input(event: InputEvent) -> void:
	if event.device != _device_id:
		return
	if event.is_action_pressed(cast_action) and has_spell():
		_cast_current()

func _cast_current() -> void:
	match current_spell:
		SpellID.FIREBALL:
			_cast_fireball()
		SpellID.SHIELD:
			_cast_shield()
	current_spell = -1

func _cast_fireball() -> void:
	if fireball_scene == null or _player == null:
		push_error("SpellCaster: fireball_scene not set or no player")
		return
	var fb := fireball_scene.instantiate() as RigidBody3D
	var origin: Vector3
	var forward: Vector3
	if _muzzle != null:
		origin = _muzzle.global_transform.origin
		forward = -_muzzle.global_transform.basis.z
	else:
		origin = _player.global_transform.origin + Vector3(0, 1.4, 0)
		forward = -_player.global_transform.basis.z
	var basis := Basis().looking_at(forward, Vector3.UP)
	fb.global_transform = Transform3D(basis, origin)
	fb.set("shooter", _player)
	get_tree().current_scene.add_child(fb)

func _cast_shield() -> void:
	if shield_scene == null or _player == null:
		push_error("SpellCaster: shield_scene not set or no player")
		return
	var s := shield_scene.instantiate() as Area3D
	s.set("owner_player", _player)
	s.set("owner_caster", self)
	get_tree().current_scene.add_child(s)

func filter_knockback(strength: float) -> float:
	return strength * clamp(shield_absorb_scale, 0.0, 1.0) if shield_active else strength

func _on_shield_started(absorb_scale: float) -> void:
	shield_active = true
	shield_absorb_scale = absorb_scale

func _on_shield_ended() -> void:
	shield_active = false
	shield_absorb_scale = 1.0
