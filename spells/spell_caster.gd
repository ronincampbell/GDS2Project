extends Node
class_name SpellCaster

var current_spell: int = -1

@export var fireball_scene: PackedScene
@export var shield_scene: PackedScene

@export var cast_action: String = "use_spell_p1"

var shield_active: bool = false
var shield_absorb_scale: float = 0.9  #percentage of knockback absorbed by shield
var _player: CharacterBody3D

@onready var _muzzle: Node3D = get_parent().get_node_or_null("Muzzle")

func _ready() -> void:
	_player = get_parent() as CharacterBody3D
	if _player == null:
		push_error("SpellCaster must be a child of a CharacterBody3D")
	set_process(true)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(cast_action):
		use_spell()

func has_spell() -> bool:
	return current_spell != -1

func can_accept_spell() -> bool:
	return !has_spell()

func add_spell(spell_id: int) -> void:
	if can_accept_spell():
		current_spell = spell_id

func use_spell() -> void:
	if current_spell == -1:
		return
	match current_spell:
		SpellPickup.SpellID.FIREBALL:
			_cast_fireball()
		SpellPickup.SpellID.SHIELD:
			_cast_shield()
		_:
			print("Spell not implemented:", current_spell)
	current_spell = -1

func _cast_fireball() -> void:
	if fireball_scene == null or _player == null:
		push_error("SpellCaster: fireball_scene not set or no player")
		return
	var f: Fireball = fireball_scene.instantiate() as Fireball
	var spawn_xf: Transform3D = _muzzle.global_transform if is_instance_valid(_muzzle) else _player.global_transform
	f.global_transform = spawn_xf
	f.shooter = _player
	f.speed = 48.0
	f.strength = 22.0
	f.splash_radius = 2.0
	_player.get_tree().current_scene.add_child(f)

func _cast_shield() -> void:
	if shield_scene == null or _player == null:
		push_error("SpellCaster: shield_scene not set or no player")
		return
	var s: Shield = shield_scene.instantiate() as Shield
	s.owner_player = _player
	s.owner_caster = self
	s.duration = 3.0
	s.radius = 1.2
	s.reflect_projectiles = true
	s.absorb_knockback_scale = 0.2
	_player.get_tree().current_scene.add_child(s)

# add a line in player knockback for calling this so that shields reduce all knockback
func filter_knockback(strength: float) -> float:
	if shield_active:
		return strength * clamp(shield_absorb_scale, 0.0, 1.0)
	return strength

func _on_shield_started(absorb_scale: float) -> void:
	shield_active = true
	shield_absorb_scale = absorb_scale

func _on_shield_ended() -> void:
	shield_active = false
	shield_absorb_scale = 1.0
