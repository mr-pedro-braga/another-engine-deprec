extends KinematicBody2D

export var gravity_angle = 90	# In degrees
export var gravity_module = 0	# In px/s²
export var velocity = Vector2(0, 32)
export var life_time = 2.0
export var acceleration = 0 	# In px/s²

func set_projectile(animation, speed, angle, life):
	life_time = life
	velocity = speed * Vector2(cos(angle), sin(angle))
	if $"Animation".frames.has_animation(animation):
		$"Animation".play(animation)
	$Timer.wait_time = life_time
	$Timer.start()

func vfloor(v:Vector2):
	return Vector2(floor(v.x), floor(v.y))

func _physics_process(delta: float) -> void:
	move_and_collide(velocity * delta)

# Timing
signal timer_end

var timer

func _emit_timer_end_signal():
	emit_signal("timer_end")


func _on_Timer_timeout():
	queue_free()
