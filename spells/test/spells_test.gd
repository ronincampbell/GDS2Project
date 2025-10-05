extends Node3D

@export var player_scene: PackedScene
@export var pickup_scene: PackedScene
@export var fireball_scene: PackedScene
@export var shield_scene: PackedScene

@export var toggle_emitters_action: StringName = &"ui_focus_next"
@export var spawn_shield_action: StringName = &"ui_accept"
@export var clear_projectiles_action: StringName = &"ui_cancel"

var _emitters: Array[Node] = []

func _ready() -> void:
	_ensure_environment()
	_spawn_player_with_caster(Vector3(0, 0, 6), 0)
	_spawn_pickups()
	_spawn_emitters()

func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed(toggle_emitters_action):
		for em in _emitters:
			if em.is_processing():
				em.stop()
			else:
				em.start()
	if e.is_action_pressed(spawn_shield_action):
		_direct_spawn_shield_on_player()
	if e.is_action_pressed(clear_projectiles_action):
		_clear_fireballs()

func _ensure_environment() -> void:
	if get_node_or_null("Ground") == null:
		var ground := StaticBody3D.new()
		ground.name = "Ground"
		var cs := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(30, 1, 30)
		cs.shape = box
		cs.position = Vector3(0, -0.5, 0)
		ground.add_child(cs)
		add_child(ground)

	if get_node_or_null("Light") == null:
		var l := DirectionalLight3D.new()
		l.name = "Light"
		l.rotation_degrees = Vector3(-45, 30, 0)
		add_child(l)

	if get_node_or_null("Camera3D") == null:
		var cam := Camera3D.new()
		cam.name = "Camera3D"
		cam.position = Vector3(0, 7, 12)
		cam.look_at(Vector3(0, 1.5, 0), Vector3.UP)
		add_child(cam)

func _spawn_player_with_caster(pos: Vector3, device_id: int) -> void:
	var player: Node3D
	if player_scene != null:
		player = player_scene.instantiate()
		player.script = load("res://spells/test/player_controller_test.gd")
	else:
		var rb := RigidBody3D.new()
		rb.name = "Player"
		rb.mass = 1.0
		var pm := PhysicsMaterial.new()
		pm.friction = 1.0
		pm.bounce = 0.0
		rb.physics_material_override = pm
		rb.script = load("res://spells/test/player_controller_test.gd")
		player = rb

	player.global_position = pos

	var caps := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.5
	cap.height = 1.2
	caps.shape = cap
	caps.position = Vector3(0, 0.9, 0)
	player.add_child(caps)

	var muzzle := Node3D.new()
	muzzle.name = "Muzzle"
	muzzle.position = Vector3(0, 1.4, -0.6)
	player.add_child(muzzle)

	var caster := Node.new()
	caster.name = "SpellCaster"
	caster.script = load("res://spells/spell_caster.gd")
	player.add_child(caster)

	if shield_scene != null:
		caster.set("shield_scene", shield_scene)
	if fireball_scene != null:
		caster.set("fireball_scene", fireball_scene)

	add_child(player)

func _spawn_pickups() -> void:
	if pickup_scene == null:
		pickup_scene = load("res://spells/spell_pickup.tscn")
	var p1 := pickup_scene.instantiate()
	p1.name = "PickupA"
	p1.global_position = Vector3(-3, 0.5, 0)
	add_child(p1)

	var p2 := pickup_scene.instantiate()
	p2.name = "PickupB"
	p2.global_position = Vector3(3, 0.5, 0)
	add_child(p2)

func _spawn_emitters() -> void:
	_emitters.append(_make_emitter(Vector3(-10, 1.3, 0), Vector3(1, 0, 0)))
	_emitters.append(_make_emitter(Vector3(10, 1.3, 0), Vector3(-1, 0, 0)))

func _make_emitter(pos: Vector3, forward: Vector3) -> Node3D:
	var em := Node3D.new()
	em.name = "FireballEmitter"
	em.script = load("res://spells/test/fireball_emitter.gd")
	em.global_position = pos

	var muzzle := Node3D.new()
	muzzle.name = "Muzzle"
	em.add_child(muzzle)

	var target := pos + forward.normalized()
	em.look_at(target, Vector3.UP)

	em.set("fireball_scene", fireball_scene if fireball_scene != null else load("res://spells/spells/Fireball.tscn"))
	em.set("rate_hz", 1.5)
	em.set("auto_start", true)
	em.set("use_muzzle_forward", true)
	em.set("spawn_offset", 0.6)

	add_child(em)
	return em

func _direct_spawn_shield_on_player() -> void:
	var player := get_node_or_null("Player") as PhysicsBody3D
	if player == null:
		return
	var caster := player.get_node_or_null("SpellCaster") as Node
	if shield_scene == null:
		shield_scene = load("res://spells/spells/Shield.tscn")
	var sh := shield_scene.instantiate()
	sh.set("owner_player", player)
	sh.set("owner_caster", caster)
	var muzzle := player.get_node_or_null("Muzzle") as Node3D
	sh.global_position = muzzle.global_position if muzzle != null else player.global_position
	get_tree().current_scene.add_child(sh)

func _clear_fireballs() -> void:
	for n in get_tree().get_nodes_in_group(&"Fireball"):
		n.queue_free()
	for n in get_tree().current_scene.get_children():
		if n is RigidBody3D and n.get_script() == load("res://spells/spells/fireball.gd"):
			n.queue_free()
