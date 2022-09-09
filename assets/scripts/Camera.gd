extends Camera2D
class_name BetterCamera

var _duration = 0.0
var _period_in_ms = 0.0
var _amplitude = 0.0
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _last_offset = Vector2(0, 0)

func _ready():
	set_process(true)

var offset_shake:Vector2
var offset_pan:Vector2
var offset_origin:Vector2
var off

func _draw() -> void:
	#draw_circle(Vector2.ZERO, 2, Color.white)
	pass

# Shake with decreasing intensity while there's time remaining.
func _process(delta):
	offset_origin = Vector2(0, 0.5*clamp(135 - get_node("/root/GameRoot/HUD/bottom_black_bar").position.y, 0, 15))
	
	# Only shake when there's shake time remaining.
	if _timer <= 0:
		_timer = 0
		off = offset_origin
		set_offset(offset_origin+offset_pan)
		return
	# Only shake on certain frames.
	_last_shook_timer = _last_shook_timer + delta
	# Be mathematically correct in the face of lag; usually only happens once.
	while _last_shook_timer >= _period_in_ms:
		_last_shook_timer = _last_shook_timer - _period_in_ms
		# Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
		var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
		# Noise calculation logic from http://jonny.morrill.me/blog/view/14
		var new_x = rand_range(-1.0, 1.0)
		var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
		var new_y = rand_range(-1.0, 1.0)
		var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
		_previous_x = new_x
		_previous_y = new_y
		# Track how much we've moved the offset, as opposed to other effects.
		var new_offset = Vector2(x_component, y_component)
		offset_shake=(offset_shake - _last_offset + new_offset)
		_last_offset = new_offset
	# Reset the offset when we're done shaking.
	_timer = _timer - delta
	set_offset(off+offset_shake+offset_pan)
	
	update()

# Kick off a new screenshake effect.
func shake(duration, frequency, amplitude):
	# Initialize variables.
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude
	_previous_x = rand_range(-1.0, 1.0)
	_previous_y = rand_range(-1.0, 1.0)
	# Reset previous offset, if any.
	offset_shake = (offset_shake - _last_offset)
	_last_offset = Vector2(0, 0)