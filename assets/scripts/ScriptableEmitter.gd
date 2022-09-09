extends Node2D
class_name ScriptableEmitter

var bullet_scene = load("res://assets/battle/battle_patterns/battle_sub_patterns/bullet.tscn")
var battle_box
var sscript := []
var escript := []
var attack_settings = {
	"type": "wait",
}

var damage = {
	"amount": 2.0,
	"element": "physical",
	"type": "normal"
}

var attack_timer_clock

func setup():
	yield(get_tree().create_timer(0.5), "timeout")
	attack_timer_clock = Timer.new()
	add_child(attack_timer_clock)
	attack_timer_clock.wait_time = 0.1
	init_emitter()
	match attack_settings.type:
		# If Type is Bullets, connect "tick" to the Timer's timeout.
		1:
			#battle_box.get_node("Anim").play(attack_settings.anim_in)
			attack_timer_clock.connect("timeout", self, "tick")
			attack_timer_clock.start()

func init_emitter():
	for l in escript:
		match l.type:
			"type":
				attack_settings.type = l.value
			"bullet_count":
				burst_size = l.value
			"script":
				sscript = l.content
			"param":
				attack_settings[l.param] = l.value
				match l.param:
					"clock_interval":
						attack_timer_clock.wait_time = attack_settings.clock_interval

var bullets_spawned = 0
var bursts_spawned = 0
var burst_size = 8

func tick():
	var burst_index = 0
	for b in range(burst_size):
		var i = bullet_scene.instance()
		i.sscript = sscript
		i.unique_id = bullets_spawned
		i.burst_id = bursts_spawned
		i.burst_index = burst_index
		add_child(i)
		#i.position = battle_box.position
		burst_index += 1
		bullets_spawned += 1
	bursts_spawned += 1
