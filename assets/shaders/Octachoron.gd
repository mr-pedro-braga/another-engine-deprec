extends MeshInstance

func _process(delta):
	rotate(
		Vector3(
			sin(Utils.time), cos(Utils.time), 0.0	
		), delta * 3
	)
	
	var s = 1.0 + 0.3 * sin(Utils.time*2)
	scale = Vector3(s, s, s)
	get_parent().get_parent().rect_position.y = -32 + 8*s
	
	var r = 0.6 + 0.3 * sin(Utils.time*5 + 0)
	var g = 0.6 + 0.3 * sin(Utils.time*5 + TAU/3)
	var b = 0.6 + 0.3 * sin(Utils.time*5 + 2 * TAU/3)
	
	var col = Color(r, g, b)
	get_parent().get_node("WorldEnvironment").environment.ambient_light_color = col

