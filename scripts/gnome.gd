extends RigidBody3D

enum ArmState {EMPTY, PROP, CLUB, AIMING}
enum BodyState {DISABLED, MOVING, STUNNED}

const move_force: float = 40.0
const max_walk_speed: float = 3.0

var arm_state: ArmState = ArmState.EMPTY
var body_state: BodyState = BodyState.MOVING
@onready var golf_interact_area: Area3D = $GolfInteractArea
@onready var prop_interact_area: Area3D = $PropInteractArea
@onready var player_interact_area: Area3D = $PlayerInteractArea
@onready var hold_marker: Marker3D = $RightArmBody/HoldMarker
@onready var prop_hold_marker: Marker3D = $PropHoldMarker
@onready var interact_indicator: Sprite3D = $InteractIndicator
@onready var ball_hit_sound: AudioStreamPlayer = $BallHitSound
@onready var bonk_sound: AudioStreamPlayer = $BonkSound

var stun_timer: float = 0.0
var disable_timer: float = 0.0

var held_prop: Node3D
var held_club: GolfClub
var aiming_ball: GolfBall

var club_pull_force_scale: float = 80.0
var prop_pull_force_scale: float = 40.0
var aim_pull_force_scale: float = 30.0
var aim_club_pull_force_scale: float = 20.0
var swing_impulse: float = -5.0
var swing_lift: float = 6.0
var swing_club_impulse: float = 8.0
var swing_club_lift: float = 10.0
var rotate_to_face_torque: float = 2.0
var swing_stun_length: float = 2.0
var min_swing_force: float = 0.1
var swing_force: float = 0.1
var increasing_force: bool = true
var swing_force_speed: float = 1.0

var player_num: int = -1:
	set(value):
		if value < 0:
			player_num = -1
			_show_color_model(0)
		else:
			player_num = value
			_show_color_model(player_num-1)
var device_id: int = 0

@onready
var color_models: Array[Node3D] = [
	$ModelBlue,
	$ModelPurple,
	$ModelRed,
	$ModelYellow,
]
@onready var left_arm_body: RigidBody3D = $LeftArmBody
@onready var right_arm_body: RigidBody3D = $RightArmBody

@onready var left_arm_mesh: MeshInstance3D = $LeftArmBody/MeshInstance3D
@onready var right_arm_mesh: MeshInstance3D = $RightArmBody/MeshInstance3D

var color_materials: Array[StandardMaterial3D] = [
	preload("res://models/gnome/placeholder_gnome_skin_blue_passthrough.tres"),
	preload("res://models/gnome/placeholder_gnome_skin_purple_passthrough.tres"),
	preload("res://models/gnome/placeholder_gnome_skin_red_passthrough.tres"),
	preload("res://models/gnome/placeholder_gnome_skin_yellow_passthrough.tres"),
]

var _caster: SpellCaster
var is_shielded: bool = false
@onready var _muzzle: Node3D = get_node_or_null("Muzzle")

func _ready() -> void:
	_caster = get_node_or_null("SpellCaster") as SpellCaster
	if _caster:
		if Engine.has_singleton("ControllerManager") and "device_players" in ControllerManager:
			for dev in ControllerManager.device_players.keys():
				if ControllerManager.device_players[dev] == player_num:
					device_id = dev
					break
		_caster.attach(self, device_id)
		#remove give_spell line later (only for testing)
		_caster.give_spell(SpellPickup.SpellID.FIREBALL)

var prev_linear_velocity: Vector3
var min_bonk_speed: float = 4.0

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if body_state == BodyState.DISABLED and disable_timer > 0.0:
		interact_indicator.hide()
		disable_timer -= get_physics_process_delta_time()
		if disable_timer <= 0.0:
			body_state = BodyState.MOVING
		return
	
	if (linear_velocity - prev_linear_velocity).length() > min_bonk_speed:
		bonk_sound.play()
	prev_linear_velocity = state.linear_velocity
	
	if body_state == BodyState.STUNNED and stun_timer > 0.0:
		interact_indicator.hide()
		stun_timer -= get_physics_process_delta_time()
		if stun_timer <= 0.0:
			body_state = BodyState.MOVING
			axis_lock_angular_x = true
			axis_lock_angular_z = true
			rotation.x = 0.0
			rotation.z = 0.0
		return
	
	if body_state == BodyState.DISABLED and disable_timer > 0.0:
		interact_indicator.hide()
		disable_timer -= get_physics_process_delta_time()
		if disable_timer <= 0.0:
			body_state = BodyState.MOVING
			axis_lock_angular_x = true
			axis_lock_angular_z = true
			rotation.x = 0.0
			rotation.z = 0.0
		return
	
	var flat_move_dir: Vector2 = Input.get_vector("PlayerLeft"+str(player_num),"PlayerRight"+str(player_num),"PlayerUp"+str(player_num),"PlayerDown"+str(player_num))
	var move_dir: Vector3 = Vector3(flat_move_dir.x, 0.0, flat_move_dir.y)
	
	if arm_state != ArmState.AIMING:
		var flat_speed: Vector3 = linear_velocity
		flat_speed.y = 0.0
		if move_dir.dot(flat_speed.normalized()) > 0.3:
			if flat_speed.length() < max_walk_speed:
				apply_central_force(move_dir*move_force)
		else:
			apply_central_force(move_dir*move_force)
		
		rotate_to_face(global_position+move_dir)
		
		if arm_state == ArmState.EMPTY:
			if _get_golf_club() or _is_close_to_prop() or _is_close_to_other_player():
				interact_indicator.show()
			else:
				interact_indicator.hide()
		elif arm_state == ArmState.CLUB:
			if _get_golf_ball():
				interact_indicator.show()
			else:
				interact_indicator.hide()
			
			_pull_club_to_hand()
		elif arm_state == ArmState.PROP:
			interact_indicator.hide()
			_pull_prop_to_self()
	else:
		if increasing_force:
			swing_force += get_physics_process_delta_time()*swing_force_speed
			if swing_force > 1.0:
				swing_force = 1.0 - (swing_force - 1.0)
				increasing_force = false
		else:
			swing_force -= get_physics_process_delta_time()*swing_force_speed
			if swing_force < min_swing_force:
				swing_force = min_swing_force + (min_swing_force - swing_force)
				increasing_force = true
		aiming_ball.aim_with_force(swing_force)
		
		_pull_club_to_hand()
		interact_indicator.hide()
		aiming_ball.aim_in_dir(move_dir)
		var stand_offset: Vector3 = aiming_ball.get_3d_aim_dir().rotated(Vector3.UP, PI/2)
		var stand_pos: Vector3 = aiming_ball.global_position + stand_offset
		var diff: Vector3 = stand_pos - global_position
		apply_central_force(diff * aim_pull_force_scale)
		
		var head_offset: Vector3 = aiming_ball.get_3d_aim_dir().rotated(Vector3.UP, PI)
		var head_pos: Vector3 = aiming_ball.global_position + head_offset
		diff = head_pos - held_club.get_head_global_pos()
		held_club.apply_force(diff * aim_club_pull_force_scale, held_club.get_head_force_offset())
		
		rotate_to_face(aiming_ball.global_position)

func rotate_to_face(target: Vector3):
	var dir_to_target: Vector3 = global_position.direction_to(target)
	dir_to_target.y = 0
	var orthogonal_dir: Vector3 = dir_to_target.normalized().rotated(Vector3.UP,-PI/2)
	var rotation_error: float = -global_basis.z.dot(orthogonal_dir)
	apply_torque(Vector3(0,rotation_error*rotate_to_face_torque,0))

func start_disable(disable_time: float):
	disable_timer = disable_time
	body_state = BodyState.DISABLED

func start_stun(stun_time: float):
	axis_lock_angular_x = false
	axis_lock_angular_z = false
	stun_timer = stun_time
	body_state = BodyState.STUNNED

func _show_color_model(index: int):
	for i in color_models.size():
		if i == index:
			color_models[i].show()
		else:
			color_models[i].hide()
	left_arm_mesh.set_surface_override_material(0, color_materials[index])
	right_arm_mesh.set_surface_override_material(0, color_materials[index])

func _pull_club_to_hand():
	var handle_pos: Vector3 = held_club.get_handle_global_pos()
	var diff: Vector3 = hold_marker.global_position - handle_pos
	held_club.apply_force(diff * club_pull_force_scale, held_club.get_handle_force_offset())

func _pull_prop_to_self():
	var diff: Vector3 = prop_hold_marker.global_position - held_prop.global_position
	held_prop.apply_central_force(diff * prop_pull_force_scale)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PlayerInteract"+str(player_num)):
		if arm_state == ArmState.EMPTY:
			try_pickup()
		elif arm_state == ArmState.PROP:
			drop_prop()
		elif arm_state == ArmState.CLUB:
			try_start_aim()
		elif arm_state == ArmState.AIMING:
			swing()
	elif event.is_action_pressed("PlayerCancel"+str(player_num)):
		if arm_state == ArmState.PROP:
			drop_prop()
		elif arm_state == ArmState.CLUB:
			drop_club()
		elif arm_state == ArmState.AIMING:
			cancel_aiming()

func _get_golf_ball() -> GolfBall:
	for body in golf_interact_area.get_overlapping_bodies():
		if body is GolfBall and !body.is_being_aimed:
			return body
	return null

func _get_golf_club() -> GolfClub:
	for body in golf_interact_area.get_overlapping_bodies():
		if body is GolfClub and !body.is_held:
			return body
	return null

func _is_close_to_prop() -> bool:
	if prop_interact_area.has_overlapping_bodies():
		return true
	return false

func _is_close_to_other_player() -> bool:
	for body in player_interact_area.get_overlapping_bodies():
		if body != self and body != left_arm_body and body != right_arm_body:
			return true
	return false

func _get_closest_body_in_area(area: Area3D):
	if !area.has_overlapping_bodies():
		return null
	var overlapping_bodies: Array[Node3D] = area.get_overlapping_bodies()
	var closest_body: Node3D = null
	var closest_distance: float = -1
	for body:Node3D in overlapping_bodies:
		if body == self:
			continue
		var body_distance: float = global_position.distance_to(body.global_position)
		if body_distance < closest_distance or closest_distance < 0:
			closest_body = body
			closest_distance = body_distance
	return closest_body

func try_pickup():
	var golf_club: GolfClub = _get_golf_club()
	var closest_prop: Node3D = _get_closest_body_in_area(prop_interact_area)
	if golf_club and golf_club:
		held_club = golf_club
		held_club.is_held = true
		held_club.enable_held_damping()
		arm_state = ArmState.CLUB
	elif closest_prop:
		held_prop = closest_prop
		held_prop.start_holding()
		add_collision_exception_with(held_prop)
		arm_state = ArmState.PROP

func try_start_aim():
	var golf_ball: GolfBall = _get_golf_ball()
	if golf_ball:
		swing_force = min_swing_force
		increasing_force = true
		aiming_ball = golf_ball
		aiming_ball.is_being_aimed = true
		aiming_ball.show_aim_arrow()
		arm_state = ArmState.AIMING

func drop_prop():
	remove_collision_exception_with(held_prop)
	held_prop.stop_holding()
	held_prop = null
	arm_state = ArmState.EMPTY

func drop_club():
	held_club.is_held = false
	held_club.disable_held_damping()
	held_club = null
	arm_state = ArmState.EMPTY

func cancel_aiming():
	aiming_ball.is_being_aimed = false
	aiming_ball = null
	arm_state = ArmState.CLUB

func swing():
	var aim_dir: Vector3 = Vector3(aiming_ball.stored_aim_dir.x, 0.0, aiming_ball.stored_aim_dir.y)
	linear_velocity = Vector3.ZERO
	start_stun(swing_stun_length)
	apply_central_impulse(aim_dir*swing_impulse*swing_force+Vector3.UP*swing_lift*swing_force)
	held_club.linear_velocity = Vector3.ZERO
	held_club.apply_impulse(aim_dir.rotated(Vector3.UP,PI/2)*swing_club_impulse*swing_force+Vector3.UP*swing_club_lift*swing_force, held_club.get_head_force_offset())
	aiming_ball.launch_in_aim_direction(swing_force, player_num)
	aiming_ball.hide_aim_arrow()
	held_club.is_held = false
	held_club.disable_held_damping()
	held_club = null
	aiming_ball.is_being_aimed = false
	aiming_ball = null
	arm_state = ArmState.EMPTY
	ball_hit_sound.play()
