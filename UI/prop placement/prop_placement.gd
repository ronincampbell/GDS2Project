extends Control

@onready var hotbar = $PanelContainer/MarginContainer/GridContainer

const props_inventory: Dictionary = {"plant":preload("res://Props/prop_plant.tscn"), "fertiliser":preload("res://Props/prop_fertiliser.tscn"), "watering_can":preload("res://Props/prop_watering_can.tscn")}
const prop_slot = preload("res://UI/prop placement/prop_slot.tscn")

func _ready() -> void:
	for key in props_inventory.keys():
		var slot_instance = prop_slot.instantiate()
		hotbar.add_child(slot_instance)
		slot_instance.set_slot_prop(props_inventory.get(key))
