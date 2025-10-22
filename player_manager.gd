extends Node

signal player_got_club(player_num: int)
signal player_lost_club(player_num: int)
signal player_stunned(player_num: int)
signal player_unstunned(player_num: int)
signal player_disabled(player_num: int)
signal player_enabled(player_num: int)

var player_nodes: Array[Gnome] = []

func get_num_players_on_field() -> int:
	return player_nodes.size()

func get_num_players_in_lobby() -> int:
	return ControllerManager.device_players.size()

func get_player_node(player_num: int) -> Gnome:
	return player_nodes[player_num]

func get_player_stun_time(player_num: int) -> float:
	return player_nodes[player_num].stun_timer

func get_player_disable_time(player_num: int) -> float:
	return player_nodes[player_num].disable_timer

func can_player_move(player_num: int) -> bool:
	return player_nodes[player_num].body_state != Gnome.BodyState.DISABLED and player_nodes[player_num].body_state != Gnome.BodyState.STUNNED

func get_player_with_club() -> int:
	var player_num: int = 1
	for player: Gnome in player_nodes:
		if player.arm_state == Gnome.ArmState.CLUB or player.arm_state == Gnome.ArmState.AIMING:
			return player_num
		player_num += 1
	return -1

func notify_player_got_club(player_num: int) -> void:
	player_got_club.emit(player_num)

func notify_player_lost_club(player_num: int) -> void:
	player_lost_club.emit(player_num)

func notify_player_stunned(player_num: int) -> void:
	player_stunned.emit(player_num)

func notify_player_unstunned(player_num: int) -> void:
	player_unstunned.emit(player_num) 

func notify_player_disabled(player_num: int) -> void:
	player_disabled.emit(player_num)

func notify_player_enabled(player_num: int) -> void:
	player_enabled.emit(player_num)
