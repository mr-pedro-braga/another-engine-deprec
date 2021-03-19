extends StaticBody2D

var can_move: bool = false

func _on_PlayerSensor_body_entered(body: Node) -> void:
	if body == Gameplay.playable_character_node:
		print("Hey there!")
		can_move = false

func _on_PlayerSensor_body_exited(body: Node) -> void:
	if body == Gameplay.playable_character_node:
		print("Bye")
		can_move = true
