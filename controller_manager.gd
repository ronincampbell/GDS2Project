extends Node

signal device_joined(attached_player: int, device_num: int)
signal device_left(attached_player: int, device_num: int)

## DeviceNum -> PlayerNum
var device_players: Dictionary[int, int]

var left_input: InputEventJoypadMotion
var right_input: InputEventJoypadMotion
var up_input: InputEventJoypadMotion
var down_input: InputEventJoypadMotion

var interact_input: InputEventJoypadButton
var cancel_input: InputEventJoypadButton

var rotate_clock: InputEventJoypadMotion
var rotate_anti_clock: InputEventJoypadMotion

var next_object: InputEventJoypadButton
var previous_object: InputEventJoypadButton

var left_input_key: InputEventKey
var right_input_key: InputEventKey
var up_input_key: InputEventKey
var down_input_key: InputEventKey

var interact_input_key: InputEventKey
var cancel_input_key: InputEventKey

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	for i in range(1,5):
		InputMap.add_action("PlayerLeft"+str(i))
		InputMap.add_action("PlayerRight"+str(i))
		InputMap.add_action("PlayerUp"+str(i))
		InputMap.add_action("PlayerDown"+str(i))
		InputMap.add_action("PlayerInteract"+str(i))
		InputMap.add_action("PlayerCancel"+str(i))
		InputMap.add_action("RotateClock"+str(i))
		InputMap.add_action("RotateAntiClock"+str(i))
		InputMap.add_action("NextObject"+str(i))
		InputMap.add_action("PreviousObject"+str(i))
	
	left_input = InputEventJoypadMotion.new()
	left_input.axis = JOY_AXIS_LEFT_X
	left_input.axis_value = -1
	
	right_input = InputEventJoypadMotion.new()
	right_input.axis = JOY_AXIS_LEFT_X
	right_input.axis_value = 1
	
	down_input = InputEventJoypadMotion.new()
	down_input.axis = JOY_AXIS_LEFT_Y
	down_input.axis_value = 1
	
	up_input = InputEventJoypadMotion.new()
	up_input.axis = JOY_AXIS_LEFT_Y
	up_input.axis_value = -1
	
	interact_input = InputEventJoypadButton.new()
	interact_input.button_index = JOY_BUTTON_A
	
	cancel_input = InputEventJoypadButton.new()
	cancel_input.button_index = JOY_BUTTON_B
	
	rotate_clock = InputEventJoypadMotion.new()
	rotate_clock.axis = JOY_AXIS_RIGHT_X
	rotate_clock.axis_value = 1
	
	rotate_anti_clock = InputEventJoypadMotion.new()
	rotate_anti_clock.axis = JOY_AXIS_RIGHT_X
	rotate_anti_clock.axis_value = -1
	
	next_object = InputEventJoypadButton.new()
	next_object.button_index = JOY_BUTTON_RIGHT_SHOULDER
	
	previous_object = InputEventJoypadButton.new()
	previous_object.button_index = JOY_BUTTON_LEFT_SHOULDER
	
	
	left_input_key = InputEventKey.new()
	left_input_key.physical_keycode = KEY_A
	
	right_input_key = InputEventKey.new()
	right_input_key.physical_keycode = KEY_D
	
	up_input_key = InputEventKey.new()
	up_input_key.physical_keycode = KEY_W
	
	down_input_key = InputEventKey.new()
	down_input_key.physical_keycode = KEY_S
	
	interact_input_key = InputEventKey.new()
	interact_input_key.physical_keycode = KEY_E
	
	cancel_input_key = InputEventKey.new()
	cancel_input_key.physical_keycode = KEY_Z

func _on_joy_connection_changed(device_num: int, connected: bool):
	if connected:
		return
	
	if device_num in device_players.keys():
		drop_out_player(device_players[device_num])

## Attempt to disconnect player. Returns false if player not connected.
func drop_out_player(player_num: int) -> bool:
	for device_num in device_players:
		if device_players[device_num] == player_num:
			device_players.erase(device_num)
			
			InputMap.action_erase_events("PlayerLeft"+str(player_num))
			InputMap.action_erase_events("PlayerRight"+str(player_num))
			InputMap.action_erase_events("PlayerUp"+str(player_num))
			InputMap.action_erase_events("PlayerDown"+str(player_num))
			InputMap.action_erase_events("PlayerInteract"+str(player_num))
			InputMap.action_erase_events("PlayerCancel"+str(player_num))
			InputMap.action_erase_events("RotateClock"+str(player_num))
			InputMap.action_erase_events("RotateAntiClock"+str(player_num))
			InputMap.action_erase_events("NextObject"+str(player_num))
			InputMap.action_erase_events("PreviousObject"+str(player_num))
			print("Player %s left on Device %s" % [player_num, device_num])
			device_left.emit(player_num, device_num)
			return true
	return false

func reset_players():
	for player in device_players.values():
		drop_out_player(player)

func _on_controller_joined(device_num: int):
	var player_num: String = str(get_lowest_inactive_player())
	device_players[device_num] = get_lowest_inactive_player()
	
	var device_left_input: InputEventJoypadMotion = left_input.duplicate()
	var device_right_input: InputEventJoypadMotion = right_input.duplicate()
	var device_up_input: InputEventJoypadMotion = up_input.duplicate()
	var device_down_input: InputEventJoypadMotion = down_input.duplicate()

	var device_interact_input: InputEventJoypadButton = interact_input.duplicate()
	var device_cancel_input: InputEventJoypadButton = cancel_input.duplicate()
	
	var device_rotate_clock: InputEventJoypadMotion = rotate_clock.duplicate()
	var device_rotate_anti_clock: InputEventJoypadMotion = rotate_anti_clock.duplicate()
	
	var device_next_object: InputEventJoypadButton = next_object.duplicate()
	var device_previous_object: InputEventJoypadButton = previous_object.duplicate()
	
	device_left_input.device = device_num
	device_right_input.device = device_num
	device_up_input.device = device_num
	device_down_input.device = device_num
	device_interact_input.device = device_num
	device_cancel_input.device = device_num
	device_rotate_clock.device = device_num
	device_rotate_anti_clock.device = device_num
	device_next_object.device = device_num
	device_previous_object.device = device_num
	
	InputMap.action_add_event("PlayerLeft"+player_num, device_left_input)
	InputMap.action_add_event("PlayerRight"+player_num, device_right_input)
	InputMap.action_add_event("PlayerUp"+player_num, device_up_input)
	InputMap.action_add_event("PlayerDown"+player_num, device_down_input)
	InputMap.action_add_event("PlayerInteract"+player_num, device_interact_input)
	InputMap.action_add_event("PlayerCancel"+player_num, device_cancel_input)
	InputMap.action_add_event("RotateClock"+player_num, device_rotate_clock)
	InputMap.action_add_event("RotateAntiClock"+player_num, device_rotate_anti_clock)
	InputMap.action_add_event("NextObject"+player_num, device_next_object)
	InputMap.action_add_event("PreviousObject"+player_num, device_previous_object)
	
	print("Player %s joined on Device %s" % [player_num, device_num])
	device_joined.emit(device_players[device_num], device_num)

func _on_keyboard_joined():
	var player_num: String = str(get_lowest_inactive_player())
	device_players[-1] = get_lowest_inactive_player()
	
	InputMap.action_add_event("PlayerLeft"+player_num, left_input_key.duplicate())
	InputMap.action_add_event("PlayerRight"+player_num, right_input_key.duplicate())
	InputMap.action_add_event("PlayerUp"+player_num, up_input_key.duplicate())
	InputMap.action_add_event("PlayerDown"+player_num, down_input_key.duplicate())
	InputMap.action_add_event("PlayerInteract"+player_num, interact_input_key.duplicate())
	InputMap.action_add_event("PlayerCancel"+player_num, cancel_input_key.duplicate())
	
	print("Player %s joined on Device %s" % [player_num, -1])
	device_joined.emit(device_players[-1], -1)

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		print("Controller button!")
		if event.button_index == JOY_BUTTON_START:
			if event.device in device_players:
				return
			if get_lowest_inactive_player() >= 0:
				_on_controller_joined(event.device)
		elif event.button_index == JOY_BUTTON_BACK:
			if event.device in device_players:
				drop_out_player(device_players[event.device])
	elif event.is_action_pressed("KeyboardJoin"):
		if -1 in device_players:
			return
		if get_lowest_inactive_player() >= 0:
			_on_keyboard_joined()
	elif event.is_action_pressed("KeyboardDropout"):
		if -1 in device_players:
			drop_out_player(device_players[-1])

func get_lowest_inactive_player() -> int:
	var inactive_players = [1,2,3,4]
	for player in device_players.values():
		if player in inactive_players:
			inactive_players.erase(player)
	if inactive_players.is_empty():
		return -1
	return inactive_players[0]

func get_highest_active_player() -> int:
	var highest: int = -1
	for player in device_players.values():
		if player > highest:
			highest = player
	return highest
