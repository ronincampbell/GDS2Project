extends Node3D

@export var fireball_scene: PackedScene
@export var shield_scene: PackedScene

@export var caster_a_path: NodePath
@export var caster_b_path: NodePath

var a_caster: SpellCaster
var b_caster: SpellCaster

func _ready() -> void:
	await get_tree().process_frame

	a_caster = get_node_or_null(caster_a_path) as SpellCaster
	b_caster = get_node_or_null(caster_b_path) as SpellCaster

	assert(a_caster != null, "PlayerA is missing a SpellCaster (check the path or script).")
	assert(b_caster != null, "PlayerB is missing a SpellCaster (check the path or script).")

	if a_caster.fireball_scene == null: a_caster.fireball_scene = fireball_scene
	if b_caster.fireball_scene == null: b_caster.fireball_scene = fireball_scene
	if a_caster.shield_scene == null: a_caster.shield_scene = shield_scene
	if b_caster.shield_scene == null: b_caster.shield_scene = shield_scene

	_run_sequence()

func _run_sequence() -> void:
	await _after(0.2)
	b_caster.give_spell(SpellPickup.SpellID.FIREBALL)
	await _after(8.0)
	b_caster._cast_current()
	await _after(12.0)
	b_caster.give_spell(SpellPickup.SpellID.FIREBALL)
	await _after(6.0)
	b_caster._cast_current()

func _after(seconds: float) -> Signal:
	return get_tree().create_timer(seconds).timeout

func _spawn_fireball_at_target(from_player: PlayerDummy, to_player: PlayerDummy, speed: float, strength: float, splash: float) -> void:
	if fireball_scene == null:
		push_error("SpellTestRunner.fireball_scene not assigned"); return
	var fb: Fireball = fireball_scene.instantiate() as Fireball

	var origin: Vector3
	var forward: Vector3
	if from_player != null:
		var muzzle := from_player.get_node_or_null("Muzzle") as Node3D
		var spawn_xf: Transform3D = muzzle.global_transform if is_instance_valid(muzzle) else from_player.global_transform
		origin = spawn_xf.origin
		forward = (to_player.global_transform.origin - origin).normalized()
	else:
		origin = global_transform.origin + Vector3(0, 1.5, 0)
		forward = (to_player.global_transform.origin - origin).normalized()

	var basis := Basis().looking_at(forward, Vector3.UP)
	fb.global_transform = Transform3D(basis, origin)

	fb.shooter = from_player if from_player != null else self
	fb.speed = speed
	fb.strength = strength
	fb.splash_radius = splash

	get_tree().current_scene.add_child(fb)
