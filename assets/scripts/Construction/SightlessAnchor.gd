extends AudioStreamPlayer2D

export(float, 0.5, 2.0) var unique_pitch = 1.0

func _ready():
	modulate.a = 0.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Sightless_Echo"):
		var sight_vector:Vector2 = (position - Gameplay.playable_character_position).normalized()
		var player = Gameplay.playable_character_node
		if sight_vector.dot(Vector2(cos(player.angle*TAU/8), sin(player.angle*TAU/8))) < 0.6:
			return
		var distance = position.distance_to(player.position)
		yield(
			get_tree().create_timer(
				pow(distance/128 * delta * 60, 2)
			), "timeout")
		$Anim.play("beep")
		if distance < 24:
			pitch_scale = 2 * unique_pitch
			play()
		else:
			pitch_scale = unique_pitch
			play()
