extends Area3D
class_name SpellPickup

enum SpellID { FIREBALL, SHIELD }

@export var fireball_scene: PackedScene
@export var shield_scene: PackedScene
@export var respawn_after_pickup := true
@export var respawn_delay := 6.0
@export var copy_spell_collider := true

@onready var _hitbox: CollisionShape3D = $Hitbox
@onready var _visual: MeshInstance3D = $Visual
@onready var _mystery: MeshInstance3D = $Mystery
@onready var _reveal_timer: Timer = $Timer

var _rng := RandomNumberGenerator.new()
var _rolled_spell: int = SpellID.FIREBALL
var _revealed := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_reveal_timer.timeout.connect(_on_reveal_timer)
	set_collision_mask_value(2, true)
	_set_mystery_visible(true)
	_set_visual_mesh(null)
	_revealed = false

func _on_reveal_timer() -> void:
	_rng.randomize()
	var pick := _rng.randi() % 2
	_rolled_spell = SpellID.FIREBALL #if pick == 0 else SpellID.SHIELD
	_apply_visual_for_roll()
	_revealed = true

func _apply_visual_for_roll() -> void:
	if _rolled_spell == SpellID.FIREBALL and fireball_scene:
		var fb := fireball_scene.instantiate()
		var col := _find_first_collision_shape(fb)
		if copy_spell_collider and col and _hitbox:
			_hitbox.shape = col.shape.duplicate(true)
		_set_visual_mesh(_get_mesh(fb))
		if is_instance_valid(fb): fb.queue_free()
	elif _rolled_spell == SpellID.SHIELD and shield_scene:
		var sh := shield_scene.instantiate()
		var col2 := _find_first_collision_shape(sh)
		if copy_spell_collider and col2 and _hitbox:
			_hitbox.shape = col2.shape.duplicate(true)
		_set_visual_mesh(_get_mesh(sh))
		if is_instance_valid(sh): sh.queue_free()

func _on_body_entered(body: Node) -> void:
	if not _revealed:
		return
	var caster := body.get_node_or_null("SpellCaster") as SpellCaster
	if caster and not caster.has_spell():
		if caster.give_spell(_rolled_spell):
			_consume_or_respawn()

func _consume_or_respawn() -> void:
	if respawn_after_pickup:
		_revealed = false
		_set_mystery_visible(true)
		_set_visual_mesh(null)
		_reveal_timer.start(respawn_delay)
	else:
		queue_free()

func _get_mesh(n: Node) -> Mesh:
	var mi := n.get_node_or_null("Visual") as MeshInstance3D
	return mi.mesh if mi != null else null

func _find_first_collision_shape(root: Node) -> CollisionShape3D:
	var stack := [root]
	while not stack.is_empty():
		var n : Variant = stack.pop_back()
		if n is CollisionShape3D:
			return n
		for c in n.get_children():
			stack.push_back(c)
	return null

func _set_visual_mesh(mesh: Mesh) -> void:
	_visual.mesh = mesh
	_visual.visible = mesh != null

func _set_mystery_visible(v: bool) -> void:
	if _mystery: _mystery.visible = v
