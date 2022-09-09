extends Node2D

export var rate = 0.5 setget set_rate
var inverse_rate
var index = 0.0
export var one_shot = false
export var random_offset:Vector2

export var emit = "bullet"
export var set_angle = false
export var bullet_sprite = "droplet"
export var bullet_bundle = 1
export var angle_offset_i = 0.0
export var radius_offset_i = 0.0
export var bullet_life = 3.0
export var bullet_speed = 64.0
export var bullet_speed_offset = 1.0
export var bullet_modulate:Color = Color.white
var damage
var life_time = 0.0
var scene_bullet

func set_rate(value):
	rate = value
	inverse_rate = 1/value

func _ready():
	randomize()
	scene_bullet = load("res://assets/battle/battle_patterns/battle_sub_patterns/"+emit+".tscn")
	inverse_rate = 1/rate
	if one_shot:
		for _i in range(rate):
			spawn_bullet()
		queue_free()
		return
	self._create_timer(self, life_time, true, "_emit_timer_end_signal")
	yield(self, "timer_end")
	queue_free()

var timeout = 0.0

func _process(delta):
	if not one_shot:
		timeout += delta
		if timeout >= inverse_rate:
			timeout = 0
			spawn_bullet(bullet_bundle)

func spawn_bullet(count=1):
	var offset:Vector2 = vrandom(random_offset)
	for _i in range(count):
		var k = scene_bullet.instance()
		k.get_node("Damage").damage = damage
		add_child(k)
		k.position = offset
		var a = deg2rad(angle_offset_i * index + 180)
		k.position = k.position + Vector2(cos(a), sin(a)) * radius_offset_i
		k.set_projectile(bullet_sprite,
						bullet_speed + random(-bullet_speed_offset, bullet_speed_offset),
						rotation + index * deg2rad(angle_offset_i),
						bullet_life)
		if not set_angle:
			k.rotation = -self.rotation
		k.modulate = bullet_modulate
		index += 1

signal timer_end
var timer

func _emit_timer_end_signal():
	emit_signal("timer_end")

func _create_timer(object_target, float_wait_time, bool_is_oneshot, string_function):
	timer = Timer.new()
	timer.set_one_shot(bool_is_oneshot)
	timer.set_timer_process_mode(0)
	timer.set_wait_time(float_wait_time)
	timer.connect("timeout", object_target, string_function)
	self.add_child(timer)
	timer.start()

func random(x, y):
	return (randf() * (y-x)) + x

func vrandom(a):
	return Vector2(random(-a.x, a.x), random(-a.y, a.y))
