extends Area2D

func _on_Damage_body_entered(body):
	if body.name == "Kuro":
		get_parent().on_hit(body)

func _on_Damage_body_exited(_body):
	pass # Replace with function body.
