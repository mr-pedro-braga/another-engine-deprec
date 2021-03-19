#
#
#	A simple throwaway class that has the same behaviour as Tween.
#	That is because I'm an idiot and didn't know Tween exists.
#
#


extends Node
class_name AnimationInstance

enum mode {
	LINEAR,
	EASE_OUT,
	EASE_IN_OUT
}

var timer:Timer
var duration
var animation_type = mode.LINEAR
var animation_property = 0
var animation_data = {}

func _ready():
	timer = Timer.new()
	timer.one_shot = true
	timer.autostart = true
	timer.wait_time = duration
	timer.connect("timeout", self, "end")
	add_child(timer)

func end():
	Utils.emit_signal("slide_finished", get_parent().name)
	queue_free()

func _process(_delta):
	if not is_inside_tree() or timer.time_left <= 0:
		return
	var obj:Node2D = get_parent()
	var property:Vector2
	match animation_type:
		mode.LINEAR:
			var p = 1.0-timer.time_left/duration
			property = lerp(animation_data["a"], animation_data["b"], p)
		mode.EASE_OUT:
			var p = timer.time_left/duration
			property = lerp(animation_data["a"], animation_data["b"], 1.0-p*p*p)
		mode.EASE_IN_OUT:
			var p = 1.0 - timer.time_left/duration
			p = p * p * (3.0 - 2.0 * p)
			property = lerp(animation_data["a"], animation_data["b"], p)
	match animation_property:
		0:
			obj.position = property
		1:
			Gameplay.main_camera.offset_pan = property
			
