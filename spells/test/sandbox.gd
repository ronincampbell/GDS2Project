extends Node3D

@export var p2_path: NodePath
@export var fallback_shield_scene: PackedScene

@onready var p2: Node3D = get_node_or_null(p2_path) as Node3D

func _ready() -> void:
	_run_sequence()

func _run_sequence() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

	if p2 == null:
		push_error("sandbox.gd: p2_path is not set or points to a missing node.")
		return

	if p2 is RigidBody3D:
		(p2 as RigidBody3D).sleeping = false

	var c2: SpellCaster = _find_spell_caster(p2)
	if c2 == null:
		push_error("sandbox.gd: SpellCaster not found under P2; direct-spawning shield.")
		_direct_spawn_shield(p2, _pick_shield_scene(null), null)
		return
	print_debug("sandbox.gd: Found P2 SpellCaster: ", c2)

	if c2.has_method("has_spell") and c2.has_method("give_spell") and c2.has_method("_cast_current"):
		if c2.has_spell():
			if "current_spell" in c2:
				c2.current_spell = -1
				print_debug("sandbox.gd: Cleared P2 current spell")

	var gave: bool = false
	if c2.has_method("give_spell"):
		gave = c2.give_spell(SpellCaster.SpellID.SHIELD)
	print_debug("sandbox.gd: give_spell(SHIELD) -> ", gave)

	var cast_called: bool = false
	if gave:
		if c2.has_method("_cast_current"):
			c2._cast_current()
			cast_called = true
			print_debug("sandbox.gd: _cast_current() called")
		elif c2.has_method("_cast_shield"):
			c2._cast_shield()
			cast_called = true
			print_debug("sandbox.gd: _cast_shield() called")

	await get_tree().process_frame

	if not cast_called:
		print_debug("sandbox.gd: No caster method called; direct-spawning fallback shield.")
		var scene: PackedScene = _pick_shield_scene(c2)
		_direct_spawn_shield(p2, scene, c2)

func _find_spell_caster(root: Node) -> SpellCaster:
	var queue: Array[Node] = [root]
	while queue.size() > 0:
		var n: Node = queue.pop_front()
		if n is SpellCaster:
			return n as SpellCaster
		var children: Array[Node] = n.get_children()
		for child in children:
			queue.push_back(child)
	return null

func _pick_shield_scene(caster: SpellCaster) -> PackedScene:
	var scene: PackedScene = fallback_shield_scene
	if caster != null:
		var sc_var: Variant = caster.get("shield_scene")
		var sc: PackedScene = sc_var as PackedScene
		if sc != null:
			scene = sc
	return scene

func _direct_spawn_shield(owner: Node3D, scene: PackedScene, caster: SpellCaster) -> void:
	if scene == null:
		push_error("sandbox.gd: No Shield scene available (assign fallback_shield_scene or set SpellCaster.shield_scene).")
		return

	var sh_area: Area3D = scene.instantiate() as Area3D
	if sh_area == null:
		push_error("sandbox.gd: Shield scene does not instance to Area3D.")
		return

	sh_area.set("owner_player", owner)
	sh_area.set("owner_caster", caster)

	var muzzle: Node3D = owner.get_node_or_null("Muzzle") as Node3D
	if muzzle != null:
		sh_area.global_position = muzzle.global_position
	else:
		sh_area.global_position = owner.global_position

	get_tree().current_scene.add_child(sh_area)
	print_debug("sandbox.gd: Direct-spawned Shield at ", sh_area.global_position)
