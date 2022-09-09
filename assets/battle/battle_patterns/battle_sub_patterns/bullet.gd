extends KinematicBody2D
class_name Projectile

export var gravity_angle = TAU/4	# In radians
export var gravity_module = 0	# In px/s²
var velocity = Vector2(32, 16)
export var life_time = 2.0

export var acceleration_angle = 0
export var acceleration = 0 	# In px/s²

export var sprite_angle = 0 # in radians

var unique_id = 0
var section_id = 0
var burst_id = 0
var burst_index = 0

#@ The type of damage this bullet deals (how you should dodge it)
var damage_mode = 0
#@ The scale of damage compared to the emitter's damage value.
var damage_scale = 1

export var speed = 32			# In px/s
export var angle = TAU/8 			# In radians
var alive_time = 0
var sscript := []
var first_turn = true
# Bullet script for this bullet already in JSON form!

func eval_condition(c, delta):
	match c:
		"%%FIRST_TURN":
			return first_turn
		_:
			var e = Expression.new()
			var error = e.parse(c, request_variable_names())
			return e.execute(      request_variable_values())

#@ Request the script variable's names.
func request_variable_names():
	return ["alive_time", "unique_id", "angle", "speed", "position", "burst_id", "burst_index"]

#@ Request the script variable's values.
func request_variable_values():
	return [alive_time, unique_id, angle, speed, position, burst_id, burst_index]

func process_script(s, delta):
	for line in s:
		match line.type:
			"condition":
				if eval_condition(line.condition, delta):
					process_script(line.content, delta)
			"sprite":
				$Animation.play(line.value)
			"param":
				var e = Expression.new()
				var error = e.parse(line.value, request_variable_names())
				var value = e.execute(request_variable_values(), self, true)
				match line.param:
					"life_time":
						life_time = value
					"position":
						position = value
					"angle":
						angle = value
						sprite_angle = angle
						acceleration_angle = angle
					"acceleration_angle":
						acceleration_angle = value
					"sprite_angle":
						sprite_angle = value
					"speed":
						speed = value
					"accel":
						acceleration = value
					"gravity_angle":
						gravity_angle = value
					"soul_gravity_angle":
						Utils.arena_status.gravity = value
					"battle_box_position":
						get_parent().battle_box.position = value
					"gravity":
						gravity_module = value
					"damage_mode":
						damage_mode = value
						match damage_mode:
							0:
								modulate = Color.white
							1:
								modulate = Color(0.705872, 0.382813, 1)
							2:
								modulate = Color.orange
					"damage_scale":
						damage_scale = value
			"log":
				print(line.value)
			"torus_border":
				var p = position + Utils.battle_box_size*5
				p = Vector2(
					fmod(p.x, Utils.battle_box_size.x*10),
					fmod(p.y, Utils.battle_box_size.y*10)
				)
				p -= Utils.battle_box_size*5
				position = p
			"process":
				if line.value == 1:
					$Animation.rotation = sprite_angle
					velocity = speed * Vector2(cos(angle), sin(angle))
					velocity += delta * acceleration * Vector2(cos(acceleration_angle), sin(acceleration_angle))
					velocity += delta * gravity_module * Vector2(cos(gravity_angle), sin(gravity_angle))
					speed = velocity.length()
					angle = velocity.angle()
					move_and_collide(velocity * delta)
			"delete":
				queue_free()
	first_turn = false

func _process(delta):
	#Discretization effect!
	#$Animation.position = (position - vfloor(position))-Vector2.ONE
	
	#Damage-when-moving effect!
	if damage_mode == 1:
		modulate.a = 0.3 + 0.7 * (Utils.current_kuro.velocity.length() / Utils.current_kuro.MAX_SPEED)
	
	alive_time += delta
	process_script(sscript, delta)
	if alive_time > life_time:
		queue_free()

var process_projectile = true
var process_gravity = false

func set_projectile(animation, speed, angle, life):
	life_time = life
	angle = angle
	if $"Animation".frames.has_animation(animation):
		$"Animation".play(animation)
	$Timer.wait_time = life_time
	$Timer.start()

func vfloor(v:Vector2):
	return Vector2(floor(v.x), floor(v.y))

# Timing
signal timer_end

var timer

func _emit_timer_end_signal():
	emit_signal("timer_end")

#@ What happens when the player is hit!
func on_hit(body):
	if Utils.current_kuro == null:
		return
	if damage_mode == 0 or damage_mode == 1 and Utils.current_kuro.velocity.length_squared() > 0 or damage_mode == 2 and Utils.current_kuro.velocity.length_squared() == 0:
		var d = get_parent().damage
		d.amount = d.amount * damage_scale
		AudioManager.play_sound("SFX_Hurt")
		if BattleCore.battle_target is String:
			return
		Utils.damage(BattleCore.battle_target.character_id, d)
		#queue_free()

func _on_Timer_timeout():
	queue_free()
