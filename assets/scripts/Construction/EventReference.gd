extends Area2D
class_name EventReference

enum TriggerMode {
	ON_TOUCH, ON_INTERACT, ON_INTERACT_FACING, ON_CONTINUOUS_TOUCH, EXISTS
}

export(TriggerMode) var trigger_mode

enum CharacterDirection {
	KEEP = -1, EAST = 0, SOUTHEAST = 1, SOUTH = 2, SOUTHWEST = 3, WEST = 4, NORTHWEST = 5, NORTH = 6, NORTHEAST = 7
}
export(CharacterDirection) var min_facing_angle
export(CharacterDirection) var max_facing_angle

export var one_shot: bool = false

var overlapping: bool = false
var activated: bool = false

func _ready():
	if not is_connected("body_entered", self, "_event_body_entered"):
		connect("body_entered", self, "_event_body_entered")
		connect("body_exited", self, "_event_body_exited")

#@ A virtual function that should be implemented by each event type.
func _on_activated():
	pass

func _process(_delta):
	if (not Engine.editor_hint):
		if Gameplay.LOADING:
			return
	
	if activated:
		return
	
	if trigger_mode == TriggerMode.EXISTS:
		_on_activated()
		if one_shot:
			queue_free()
		return
	if (overlapping
		and not Gameplay.in_dialog
		and not Gameplay.map_characters[Gameplay.playable_character].in_route
		and not Gameplay.in_event ):
			if Input.is_action_pressed("ghost"):
				return
			match trigger_mode:
				3:
					_on_activated()
					if one_shot:
						activated = true
				2:
					if Input.is_action_just_pressed("ok") and Gameplay.playable_character_node.angle >= min_facing_angle and Gameplay.playable_character_node.angle <= max_facing_angle:
						_on_activated()
						if one_shot:
							activated = true
				1:
					if Input.is_action_just_pressed("ok"):
						_on_activated()
						if one_shot:
							activated = true
				0:
					if not activated:
						_on_activated()
						activated = true

func _event_body_entered(body) -> void:
	if body is Character and body.character_id == Gameplay.playable_character:
		overlapping = true

func _event_body_exited(body) -> void:
	if body is Character and body.character_id == Gameplay.playable_character:
		overlapping = false
		if not one_shot:
			activated = false
