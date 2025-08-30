extends Area3D
class_name SpellPickup

enum SpellID { FIREBALL, SHIELD }

const SPELL_DEF := {
	SpellID.FIREBALL: {"name": "Fireball", "shape": "sphere", "r": 0.7, "mesh": "sphere"},
	SpellID.SHIELD: {"name": "Shield", "shape": "capsule", "r": 0.45, "h": 0.7, "mesh": "capsule"}
}

@export var respawn_after_pickup := false
@export var respawn_delay := 6.0

@onready var _hitbox: CollisionShape3D = %Hitbox
@onready var _visual: MeshInstance3D = %Visual
@onready var _mystery: MeshInstance3D = %Mystery
@onready var _reveal_timer: Timer = %Timer

var _rolled_spell: int = SpellID.FIREBALL
var _revealed := false

func _ready() -> void:
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
	var keys := SPELL_DEF.keys()
	return keys[randi() % keys.size()]

func _str(def: Dictionary, key: String, default_val: String) -> String:
	return String(def[key]) if def.has(key) else default_val

func _f(def: Dictionary, key: String, default_val: float) -> float:
	return float(def[key]) if def.has(key) else default_val

func _v3(def: Dictionary, key: String, default_val: Vector3) -> Vector3:
	if def.has(key) and def[key] is Vector3:
		return def[key] as Vector3
	return default_val

func _apply_spell_visuals(spell_id: int) -> void:
	var def: Dictionary = SPELL_DEF.get(spell_id, {})
	if def.is_empty(): return
	_hitbox.shape = _build_shape(def)
	_set_visual_mesh(_build_mesh(def))
	_set_mystery_visible(false)

func _build_shape(def: Dictionary) -> Shape3D:
	match def.get("shape"):
		"sphere":
			var s := SphereShape3D.new()
			s.radius = def.get("r", 0.6)
			return s
		"capsule":
			var c := CapsuleShape3D.new()
			c.radius = def.get("r", 0.4)
			c.height = def.get("h", 0.6)
			return c
		"box":
			var b := BoxShape3D.new()
			b.size = def.get("size", Vector3.ONE * 0.6)
			return b
		_:
			return SphereShape3D.new()

func _build_mesh(def: Dictionary) -> Mesh:
	var kind: String = _str(def, "mesh", _str(def, "shape", "sphere"))
	match kind:
		"sphere":
			var m := SphereMesh.new()
			m.radius = def.get("r", 0.6)
			return m
		"capsule":
			var m2 := CapsuleMesh.new()
			m2.radius = def.get("r", 0.4)
			m2.height = def.get("h", 0.6)
			return m2
		"box":
			var m3 := BoxMesh.new()
			m3.size = def.get("size", Vector3.ONE * 0.6)
			return m3
		_:
			return SphereMesh.new()

func _set_visual_mesh(mesh: Mesh) -> void:
	_visual.mesh = mesh
	_visual.visible = mesh != null

func _set_mystery_visible(v: bool) -> void:
	if _mystery:
		_mystery.visible = v

func _on_body_entered(body: Node) -> void:
	if not _revealed: return
	if body and body.has_method("add_spell"):
		body.add_spell(_rolled_spell)
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
