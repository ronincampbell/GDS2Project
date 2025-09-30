extends HBoxContainer

@onready var icon = $IconContainer/PlayerIcon
@onready var viewport = $IconContainer/PlayerIcon/SubViewport
@onready var timer = $IconContainer/IncapTimer
@onready var score = $ScoreContainer/ScoreMargin/ScoreText
@onready var arrow = $IconContainer/Arrow

var is_timer_active: bool = false
var countdown: float = 0.0
var camera

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
	
func update_timer(stun_length: float = 0.0, is_visible: bool = true):
	if is_visible:
		if !timer.visible: 
			timer.show()
			is_timer_active = true
			countdown = stun_length
		else:
			timer.text = str(snappedf(countdown, 0.1))
	else:
		timer.hide()
		is_timer_active = false

func update_arrow():
	if !camera && get_tree().current_scene:
		camera = get_tree().current_scene.get_viewport().get_camera_3d()
	if camera:
		var gnome_pos_on_screen = Vector2(0, 0)#= camera.unproject_position(gnome's 3d position here)
		var angle_to_gnome = arrow.position.angle_to_point(gnome_pos_on_screen)
		arrow.rotation = angle_to_gnome
