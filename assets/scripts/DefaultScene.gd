class_name DefaultScene
extends EventEssentials

export var scene_name = "Scene 1"
export var initial_zoom = 1.0

func _ready():
	Gameplay.update_zoom(initial_zoom)
