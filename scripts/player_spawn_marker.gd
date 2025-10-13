extends Marker3D

@onready var spotlight : SpotLight3D = $SpotLight3D

func _ready() -> void:
	spotlight.show()

func set_visibility(set_to : bool) -> void:
	spotlight.visible = set_to
