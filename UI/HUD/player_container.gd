extends HBoxContainer

@onready var icon = $IconContainer/PlayerIcon
@onready var viewport = $IconContainer/PlayerIcon/SubViewport
@onready var timer = $IconContainer/IncapTimer
@onready var score = $ScoreContainer/ScoreMargin/ScoreText

var is_timer_active: bool = false

var countdown: float = 0.0

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
