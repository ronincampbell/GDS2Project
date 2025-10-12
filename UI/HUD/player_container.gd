extends HBoxContainer

@onready var icon = $IconContainer/PlayerIcon
@onready var viewport = $IconContainer/PlayerIcon/SubViewport
@onready var timer = $IconContainer/IncapTimer
@onready var score = $OtherContainer/ScoreContainer/ScoreMargin/ScoreText
@onready var arrow = $IconContainer/Arrow
@onready var crown = $CrownControlNode/GnomeCrown
@onready var spell = $OtherContainer/SpellContainer/PanelContainer/SpellIcon
@onready var spell_control = $OtherContainer/SpellContainer/ControlIcon

var is_timer_active: bool = false
var countdown: float = 0.0

func _ready() -> void:
	arrow.pivot_offset = Vector2(48, 48)

func _process(delta: float) -> void:
	if is_timer_active:
		icon.modulate = Color.DIM_GRAY
		var time_passed: float = 0.0
		time_passed += delta
		countdown -= time_passed
		if countdown <= 0.0:
			reset_timer()
	else:
		icon.modulate = Color.WHITE

func set_score_text(new_score: int):
	score.text = str(new_score)
	
func reset_timer():
	timer.text = "00.0"
	timer.hide()
	is_timer_active = false
	
func update_timer(stun_length: float = 0.0, is_active: bool = true):
	if is_active:
		if !timer.visible: 
			timer.show()
			is_timer_active = true
			countdown = stun_length
		else:
			timer.text = str(snappedf(countdown, 0.1))
	else:
		timer.hide()
		is_timer_active = false

func update_arrow(gnome_pos: Vector3, camera: Camera3D):
	if camera:
		var gnome_pos_on_screen = camera.unproject_position(gnome_pos)
		var angle_to_gnome = arrow.position.angle_to_point(gnome_pos_on_screen)
		arrow.rotation = -45.0
		#arrow.rotation = 0.0
		arrow.rotation += angle_to_gnome

func update_crown(is_holding_club: bool):
	if is_holding_club:
		crown.show()
	else:
		crown.hide()

func update_spell(held_spell):
	if held_spell:
		#spell.texture = held_spell.get_icon()
		spell_control.show()
	else:
		spell.texture = null
		spell_control.hide()
