###############################
#
#	Chroma RPG Utilities Class
#
###############################

extends Node

#
# @ Saving and Loading
#

#@ Loads a scene asynchronously using SceneLoader.
func async_load(resource, data={}):
	return load(resource)

#@ Loads a file as text
func load_as_text(path):
	var f = File.new()
	f.open(path, File.READ)
	var content = f.get_as_text()
	f.close()
	return content

# Loads an attack pool from a JSON or SSON file
func load_attack_pool(pool, use_sson=false):
	pass

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
var character_specs: Dictionary = {}

#@ Sets up all the character specifications
func character_system_init():
	character_specs = load_sson("res://assets/characters/character_specs.sson")

#@ Gets the specs for a character, defaults to 'default'
func get_specs(character):
	if character_specs.has(character):
		return character_specs[character]
	return character_specs["default"]

#@ Stores all the stats for the characters in battles
var character_stats:Dictionary = {
	
}

#@ Creates a character on the world given specifications
func create_character(id):
	pass


#
# @ Events
#

#@ Enter event mode, freezes other interactions
func enter_event():
	Gameplay.in_event = true

#@ Leave event mode
func leave_event():
	Gameplay.in_event = false


#
# @ Battles
#

#@ Stores the battler scripts
var battle_scripts := {}

#@ Stores the status effects that mess with the dodge_box.
var arena_status := {
	"hot_border": false,
	"torus_border": false,
	"slippery_floor": false,
}

#@ Changes the battle background to a certain BBG ID
func change_battle_bg(bbg_id):
	pass

signal act_finished
func act(actor, actee, act):
	pass

signal attack_finished
func attack(user, target, attack_pool, attack_id):
	pass

func update_soul_meters():
	pass

#
# @ Orphan functions
#

var time = 0

func _process(delta):
	time += delta

func format_special(text):
	return text

func slide_to(object, target_position, speed, mode):
	pass

func async_animate(object, property, target_property, duration, tween_mode):
	pass
