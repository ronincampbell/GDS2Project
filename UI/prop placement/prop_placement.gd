extends Control

@onready var hotbar = $HBoxContainer/PanelContainer/MarginContainer/GridContainer
@onready var timer = $Timer/MarginContainer/TimerText

const prop_models: Dictionary = {
	"plant":preload("res://Props/prop_plant.tscn"), 
	"fertiliser":preload("res://Props/prop_fertiliser.tscn"), 
	"watering_can":preload("res://Props/prop_watering_can.tscn")
	}
const prop_slot = preload("res://UI/prop placement/prop_slot.tscn")
enum players {PLAYER1, PLAYER2, PLAYER3, PLAYER4}

#props list will be populated by init_hotbar to match prop_models
var props_list = {
	"plant": 0,
}
var player_current_props = {
	players.PLAYER1: "plant",
	players.PLAYER2: "plant",
	players.PLAYER3: "plant",
	players.PLAYER4: "plant",
}

func _ready() -> void:
	init_hotbar()
	highlight_selected_props()

func init_hotbar():
	for key in prop_models.keys():
		var slot_instance = prop_slot.instantiate()
		hotbar.add_child(slot_instance)
		slot_instance.set_slot_prop(prop_models.get(key))
		props_list.get_or_add(key, slot_instance.get_index())

func highlight_selected_props():
	for prop in hotbar.get_children():
		prop.clear_selections()
	
	for player in player_current_props:
		hotbar.get_child(props_list[player_current_props[player]]).set_selections(player)

func update_selected(player_num: int, object: String) -> void:
	player_current_props[player_num] = object
	highlight_selected_props()

func update_timer_text(rem_time: float = 30.00):
	timer.text = str(rem_time)
