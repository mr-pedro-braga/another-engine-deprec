tool
class_name DefaultScene
extends EventEssentials

export var scene_name = "Scene 1"
export var scene_initial_zoom = 1.0
var initial_zoom = 0.0 setget ,aa

func aa():
	print_debug("initial_zoom_changed")
	return initial_zoom

func scene_ready():
	if not Engine.editor_hint:
		Gameplay.update_zoom(scene_initial_zoom)

func _get_property_list():
	var properties = []
	properties.append({
			name = "Scene",
			type = TYPE_NIL,
			hint_string = "scene_",
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	return properties
