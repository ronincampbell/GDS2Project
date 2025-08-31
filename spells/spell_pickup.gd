extends Area3D
class_name SpellPickup

enum SpellID { FIREBALL, SHIELD }

@export var fireball_scene: PackedScene
@export var shield_scene: PackedScene

@export var respawn_after_pickup := false
@export var respawn_delay := 6.0
@export var copy_spell_collider: bool = true

@onready var _hitbox: CollisionShape3D = $Hitbox
@onready var _visual: MeshInstance3D = $Visual
@onready var _mystery: MeshInstance3D = $Mystery
@onready var _reveal_timer: Timer = $Timer

var _rolled_spell: int = SpellID.FIREBALL
var _revealed: bool = false

var _preview_cache: Dictionary = {}

func _ready() -> void:
	randomize()
	body_entered.connect(_on_body_entered)
	_reveal_timer.timeout.connect(_on_reveal_timer)

	_set_mystery_visible(true)
	_set_visual_mesh(null)
	_revealed = false

	set_process(true)

func _process(delta: float) -> void:
	rotation.y += 1.2 * delta

func _on_reveal_timer() -> void:
	_rolled_spell = _roll_spell()
	_apply_spell_visuals(_rolled_spell)
	_revealed = true

func _roll_spell() -> int:
	var pool: Array = [SpellID.FIREBALL, SpellID.SHIELD]
	return pool[randi() % pool.size()]

func _apply_spell_visuals(spell_id: int) -> void:
	var preview := _get_preview_for(spell_id)
	var mesh := preview.get("mesh") as Mesh
	var mat  := preview.get("mat")  as Material
	_set_visual_mesh(mesh)
	_visual.material_override = mat.duplicate() if mat != null else null

	if copy_spell_collider:
		var shape := _get_collider_shape_for(spell_id)
		if shape != null:
			_hitbox.shape = shape

	_set_mystery_visible(false)

func _on_body_entered(body: Node) -> void:
	if not _revealed:
		return
	var caster := body.get_node_or_null("SpellCaster") as SpellCaster
	if caster != null and caster.can_accept_spell():
		caster.add_spell(_rolled_spell)
		if respawn_after_pickup:
			_despawn_and_schedule_respawn()
		else:
			queue_free()

func _despawn_and_schedule_respawn() -> void:
	monitoring = false
	visible = false
	await get_tree().create_timer(respawn_delay).timeout
	monitoring = true
	visible = true
	_set_mystery_visible(true)
	_set_visual_mesh(null)
	_revealed = false
	_reveal_timer.start()

func _scene_for_spell(spell_id: int) -> PackedScene:
	match spell_id:
		SpellID.FIREBALL: return fireball_scene
		SpellID.SHIELD:   return shield_scene
		_:                return null

func _get_preview_for(spell_id: int) -> Dictionary:
	if _preview_cache.has(spell_id):
		return _preview_cache[spell_id]

	var result := {"mesh": null, "mat": null}
	var scene := _scene_for_spell(spell_id)
	if scene != null:
		var inst := scene.instantiate()
		var mi := _find_first_mesh_instance(inst)
		if mi != null:
			result.mesh = mi.mesh
			if mi.material_override != null:
				result.mat = mi.material_override
			elif mi.mesh != null and mi.mesh.get_surface_count() > 0:
				result.mat = mi.mesh.surface_get_material(0)
		inst.queue_free()

	_preview_cache[spell_id] = result
	return result

func _get_collider_shape_for(spell_id: int) -> Shape3D:
	var scene := _scene_for_spell(spell_id)
	if scene == null:
		return null
	var inst := scene.instantiate()
	var cshape := _find_first_collision_shape(inst)
	var shape := cshape.shape.duplicate(true) if (cshape != null and cshape.shape != null) else null
	inst.queue_free()
	return shape

func _find_first_mesh_instance(root: Node) -> MeshInstance3D:
	var prefer: MeshInstance3D = root.get_node_or_null("Visual") as MeshInstance3D
	if prefer != null:
		return prefer
	var stack: Array[Node] = [root]
	while stack.size() > 0:
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			return n as MeshInstance3D
		for child in n.get_children():
			stack.push_back(child)
	return null

func _find_first_collision_shape(root: Node) -> CollisionShape3D:
	var prefer: CollisionShape3D = root.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if prefer != null:
		return prefer
	var stack: Array[Node] = [root]
	while stack.size() > 0:
		var n: Node = stack.pop_back()
		if n is CollisionShape3D:
			return n as CollisionShape3D
		for child in n.get_children():
			stack.push_back(child)
	return null

func _set_visual_mesh(mesh: Mesh) -> void:
	_visual.mesh = mesh
	_visual.visible = mesh != null

func _set_mystery_visible(v: bool) -> void:
	if _mystery != null:
		_mystery.visible = v
