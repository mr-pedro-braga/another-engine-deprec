extends AnimatedSprite
class_name ChoiceIcon

var choiceparent
var index=0
var angle
var angle_drag
var dx=0
var dy=0
var dx_drag=0
var dy_drag=0
var coffset=0

func _ready():
	choiceparent = get_parent()
	display()

func display():
	match choiceparent.display:
		0:
			var radius = 28
			angle = float(index - choiceparent.choice_index) / float(choiceparent.choices_count) * 2 * PI
			angle_drag = lerp_angle(angle_drag, angle, 0.3)
			position = Vector2(sin(angle_drag), -cos(angle_drag)*0.9) * (radius + sin(Utils.time*3.0+angle)if Gameplay.GAMEMODE == Gameplay.GM.BATTLE else radius)
		1:
			dx = (index-fposmod(choiceparent.choice_index,choiceparent.choices_count)) * 20
			dx_drag = lerp(dx_drag, dx, max(0.3-float(abs(choiceparent.choice_index-index))/10, 0.5))
			position = Vector2(dx_drag, -32*0.9)
		2:
			dy = (index-fposmod(choiceparent.choice_index,choiceparent.choices_count)) * 20
			dy_drag = lerp(dy_drag, dy, max(0.3-float(abs(choiceparent.choice_index-index))/10, 0.5))
			position = Vector2(-24, dy_drag)
		3:
			dy = (index-fposmod(choiceparent.choice_index,choiceparent.choices_count)) * 20
			dy_drag = lerp(dy_drag, dy, max(0.3-float(abs(choiceparent.choice_index-index))/10, 0.5))
			position = Vector2(24, dy_drag)
	position.y += coffset

func _process(_delta):
	display()

