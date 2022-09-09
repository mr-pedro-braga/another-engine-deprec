###############################
#
#	Chroma RPG Utilities Class
#
###############################

extends Node

#
# @ Utilities Process!
#

func _ready():
	if is_narrating:
		Utils.speak("Game loaded!")

# Util variables
var playtime = {
	"hours": 0,
	"minutes": 0,
	"seconds": 0,
} # Always increases.
var time: float = 0.0
var frames: int = 0
var dt: float = 0.5

func _process(delta: float) -> void:
	time += delta
	dt = delta
	frames += 1
	if Input.is_action_pressed("ff"):
		Engine.time_scale = 5.0
	else:
		Engine.time_scale = 1.0

#@ Returns the current FPS.
func fps() -> float:

	return 1.0/dt

#@ Returns the current playtime.
func playtime():
	playtime.hours = floor(time / 3600)
	playtime.minutes = floor(fmod(time, 3600) / 60)
	playtime.seconds = fmod(time, 60)
	return playtime

#
# @ Acessibility Settings
#

var is_narrating = false

#
# @ Saving and Loading
#

#@ Loads a scene asynchronously using SceneLoader.
signal scene_loaded
func async_load(resource, data={}):
	SceneLoader.load_scene(resource, data)
	var i = yield(SceneLoader, "on_scene_loaded")
	emit_signal("scene_loaded", i)

#@ Loads a file as text
func load_as_text(path):
	var f = File.new()
	f.open(path, File.READ)
	var content = f.get_as_text()
	f.close()
	return content

#@ Attack Pool Cache
var attack_pool_cache := {}

# Loads an attack pool from a SSON file
func load_attack_pool(pool):
	# IF the attack wasn't already loaded,
	if not attack_pool_cache.has(pool):
		# Load it and convert it into JSON so it can be easily read afterwards!
		attack_pool_cache[pool] = SSEX_Attack.parse_sson_atk(load_as_text("res://assets/battle/attacks/"+pool+".sson"))
	pass

# Unloads an attack pool from memory
func unload_attack_pool(pool):
	if attack_pool_cache.has(pool):
		attack_pool_cache.erase(pool)

# Loads a SSON file into a Dictonary
func load_sson(path):
	var raw = load_as_text(path)
	return SceneScript.parse_sson_dictionary(raw)

#
# @ Characters
#

#@ Stores the character specifications
# that are used whenever a character speaks in a dialog
# or are summoned into a map.
var character_specs: Dictionary = {
	"claire": {
		"portrait": "claire",
		"voice": "claire"
	},
	"andy": {
		"portrait": "andy",
		"voice": "william"
	},
	"bruno": {
		"portrait": "young_claire",
		"voice": "bruno"
	}
}

#@ The characters' statuses for the characters in battles.
var character_stats: Dictionary = {}
func set_character_acts(character, acts):
	character_stats["acts"] = acts

#@ Sets up all the character specifications
func character_system_init():
	character_specs = load_sson("res://assets/characters/character_specs.sson")

#@ Gets the specs for a character, defaults to 'default'
func get_specs(character):
	if character_specs.has(character):
		return character_specs[character]
	return character_specs["claire"]

#@ Load the stats for a character from SSON
func load_stats(character_id, char_stats_file, alignment):
	match alignment:
		"ALLY":
			if not character_stats.has(character_id):
				var file = File.new()
				file.open("res://assets/battle/party_member_stats/" + char_stats_file, File.READ)
				var text = file.get_as_text()
				Utils.character_stats[character_id] = parse_json(text)
		"OPPONENT":
			if not character_stats.has(character_id):
				var file = File.new()
				file.open("res://assets/battle/battle_scripts/" + char_stats_file, File.READ)
				var text = file.get_as_text()
				Utils.character_stats[character_id] = parse_json(text)

#@ Creates a character on the world given specifications
func create_character(id):
	pass


#
# @ Events
#

#@ Enter event mode, freezes other interactions
func enter_event():
	Gameplay.in_event = true
	for i in Gameplay.party:
		if Gameplay.map_characters.has(i):
			Gameplay.map_characters[i].stop()

#@ Leave event mode
func leave_event():
	Gameplay.in_event = false

#@ Signals for when different threads of events are waiting each other in order to progress.
signal checkpoint(name)
signal hot_second

#@ Throws a text message error instead of crashing, for better debugging workflow.
func throw_error(message):
	print("ERROR (!): ", message)

#
# @ Battles
#

#@ Stores the battler scripts
var battle_scripts := {}

#@ The current Kuro used to dodge
var current_kuro

#@ Stores the status effects that mess with the dodge_box.
var arena_status := {
	"hot_border": false,
	"torus_border": false,
	"slippery_floor": false,
	"gravity": TAU/4,
}

#@ Changes the battle background to a certain BBG ID
func change_battle_bg(bbg):
	var b = get_node("/root/GameRoot/HUD2/BattleBG")
	for i in b.get_children():
		b.visible = false
	b.get_node(bbg).visible = true

#@ When executing an action, call the ACT function in the target
signal act_finished
func act(actor, subject, action):
	if battle_scripts.has(subject):
		print_debug("(ERROR !): Subject ", subject, " has no battle script defined!")
	battle_scripts[subject.to_lower()].act(actor, action)

#@ Attack a character using a loaded attack from a known pool!
#@ Make sure to load these pools somewhere before the fight!
signal attack_finished
signal minigame_finished
func attack(user, target, attack_pool, attack_id):
	if not target is String:
		target = target.character_id
	
	if not attack_pool_cache.has(attack_pool):
		var file = load_as_text("res://assets/battle/attacks/" + attack_pool + ".sson")
		
		attack_pool_cache[attack_pool] = SSEX_Attack.parse_sson_atk(file)
	
	#@ Parse the attack from SSON into a Dictionary.
	if not attack_pool_cache[attack_pool].has(attack_id):
		print_debug("(ERROR !): The given attack id, ", attack_id, ", does not exist in the provided file \"", attack_pool,"\"")
	
	var attack_info = SSEX_Attack.read_atk( attack_pool_cache[attack_pool][attack_id] )
	match attack_info.type:
		-1:
			# Wait!
			yield(get_tree().create_timer(0.2), "timeout")
		0:
			# Minigames!
			var minigame = load("res://assets/battle/minigames/" + attack_info.minigame_source + ".scn").instance()
			minigame.target = target
			BattleCore.battle.add_child(minigame)
			yield(self, "minigame_finished")
		1:
			# Bullets!
			var emitter = ScriptableEmitter.new()
			# Parse the attack and get the information.
			emitter.escript = attack_info.content
			emitter.name = "AttackEmitter"
			emitter.battle_box = BattleCore.battle
			
			var k = Assets.kuro_scene.instance()
			k.name = "Kuro"
			current_kuro = k
			k.character = target
			#k.get_node("Anim").play("ollie")
			k.get_node("Anim").play(target)
			k.get_node("Dust").modulate = Utils.character_stats[target].attributes.trait
			
			BattleCore.battle.visible = true
			BattleCore.battle.get_node("Anim").play(attack_info.anim_in)
			yield(get_tree().create_timer(0.25), "timeout")
			
			BattleCore.battle.add_child(k)
			BattleCore.battle.add_child(emitter)
			emitter.setup()
			
			yield(get_tree().create_timer(6.0), "timeout")
			
			k.queue_free()
			emitter.queue_free()
			BattleCore.battle.get_node("Anim").play(attack_info.anim_out)
		2:
			#Animation!
			pass
	emit_signal("attack_finished")

#@ Inflict damage to a character in battle
func damage(target, damage):
	if current_camera == null:
		current_camera = Gameplay.main_camera
	current_camera.shake(0.3, 32, 2)
	if not character_stats.has(target):
		print_debug("(ERROR !): This was NOT supposed to happen.")
		return
	character_stats[target].attributes.HP -= damage.amount
	Gameplay.map_characters[target].fight_action = "hurt"
	update_soul_meter(target)
	yield(get_tree().create_timer(0.3), "timeout")
	Gameplay.map_characters[target].fight_action = "idle"

# Heal a certain character (by name)
var standard_healing = {
	"type": "HP", #Type can be any attribute!
	"amount": 1.0,
}
func heal(character, healing):
	character_stats["target"].attributes[healing.type] += healing.amount
	update_soul_meter(character)
	#TODO: Add healing VFX!

onready var soul_infos_node = get_node("/root/GameRoot/HUD/SoulInfos")
func update_soul_meter(character):
	if character in Gameplay.party:
		soul_infos_node.get_node(character.to_lower()).self_update(character.to_lower())
func update_soul_meters():
	for i in Gameplay.party:
		var si = Assets.info_scene.instance()
		var st = character_stats[i].attributes
		si.setup(i.to_lower(), st.MHP, st.HP, st.MSP, st.SP, st["hp-foreground"], st["hp-background"])
		soul_infos_node.add_child(si)
		si.self_update(i)
	pass

#
# @ Camera Management and Special Effects
#

var battle_box_size = Vector2(3, 3)
var current_camera
func make_current_camera(camera):
	current_camera = camera
	camera.make_current()

func play_transition(transition):
	if not Assets.transition_player.has_animation(transition):
		throw_error("The " + transition + " animation doesn't actually exist.")
	Assets.transition_player.play(transition)


# Visual Effects for the deaf! Also adds some cartoon value.
onready var vfx_once = load("res://assets/modular_scenes/OnceVFX.tscn")

func vfx(container, position, vfx):
	var c = vfx_once.instance()
	container.add_child(c)
	c.position = position
	c.animation = vfx

#
# @ Orphan functions
#

func speak(text, interrupt=true):
	SpeechSynth.speak(text, interrupt)
	#print("<UTILS.gd::speak> ", text)

func format_special(text):
	return text

func slide_to(object, target_position, speed, mode):
	pass

func async_animate(object, property, target_property, duration, tween_mode):
	pass
