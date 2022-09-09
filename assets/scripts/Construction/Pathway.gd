tool
extends EventReference
class_name PathwayEvent

#
#
# @ General Events Class!
#
# Useful for general events here and there.
#

export(String, FILE, "*.tscn") var target_scene = null
export(Vector2) var target_position = Vector2(0, 0) setget set_target_position
export(EventReference.CharacterDirection) var target_facing_direction = CharacterDirection.KEEP
export(String, "slide_black", "diamonds_black", "set_black", "fade_black") var transition = "slide_black"

func set_target_position(value):
	target_position = value
	update()

func _draw():
	if Engine.editor_hint:
		draw_circle(target_position - position, 4.0, Color.aqua)

# When this event gets activated
func _on_activated():
	if target_scene == null or target_scene == "":
		Gameplay.teleport(target_position, transition, target_facing_direction)
		return
	Gameplay.warp_by_path(target_scene, target_position, transition, target_facing_direction)
