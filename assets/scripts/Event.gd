extends Area2D
class_name SceneEvent

export var event = ""
export var parameter = ""
export var arguments = []
export var trigger_mode: int = 0

var overlapping: bool = false

func _process(_delta):
	if Gameplay.LOADING:
		return
	if (overlapping
		and not Gameplay.in_dialog
		and not Gameplay.map_characters[Gameplay.playable_character].in_route
		and not Gameplay.in_event ):
			if Input.is_action_pressed("ghost"):
				return
			match trigger_mode:
				1:
					if Input.is_action_just_pressed("ok"):
						get_node("/root/GameRoot/World/Scene").call("evt_" + event, self, parameter, arguments)
				0:
					get_node("/root/GameRoot/World/Scene").call("evt_" + event, self, parameter, arguments)

func _event_body_entered(body) -> void:
	if body is Character and body.character_id == Gameplay.playable_character:
		overlapping = true

func _event_body_exited(body) -> void:
	if body is Character and body.character_id == Gameplay.playable_character:
		overlapping = false
