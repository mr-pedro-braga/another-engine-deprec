extends TextureRect

var screen_size = Vector2(240, 135)
export var motion:Vector2 = Vector2.ZERO
var time = 0

func _process(delta):
	if visible:
		self_modulate = Color(sin(time), sin(time+PI/3), sin(time + 2 * PI/3))
		time += delta/2
		motion = 30 * Vector2(sin(time), cos(time))
		rect_position += motion*delta
		
		if rect_position.x > 0:
			rect_position.x -= screen_size.x
		if rect_position.x < -screen_size.x:
			rect_position.x += screen_size.x
		if rect_position.y > 0:
			rect_position.y -= screen_size.y
		if rect_position.y < -screen_size.y:
			rect_position.y += screen_size.y
