extends RigidBody3D
class_name Prop

var holding_players: int = 0

var held_linear_damping: float = 2.0
var free_linear_damping: float = 0.0
var held_angular_damping: float = 2.0
var free_angular_damping: float = 0.0

func start_holding():
	holding_players += 1
	enable_held_damping()

func stop_holding():
	holding_players -= 1
	if holding_players <= 0:
		disable_held_damping()

func enable_held_damping():
	linear_damp = held_linear_damping
	angular_damp = held_angular_damping

func disable_held_damping():
	linear_damp = free_linear_damping
	angular_damp = free_angular_damping
