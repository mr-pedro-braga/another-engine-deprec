#--------------------------------------------------------#
#
#		Another Series Gameplay
#	
#	Takes care of the CORE gameplay
#	sucha as loading worlds, scenes, and managing
#	game states.
#
#--------------------------------------------------------#


extends Node


##########

#
# @ Game State Variables
#

### If you are currently in a scene with characters
export var overworld = true
export var game_running = false
export var slider1 = 0.0

### Assets and references to important nodes.
var _Assets
onready var main_camera = get_node("/root/GameRoot/World/Camera")	# Reference to the main camera
onready var world = get_node("/root/GameRoot/World") 				# Reference to the map container
onready var transition_player = get_node("/root/GameRoot/Transition/TransitionPlayer") # Reference to the transition player
onready var dialog = get_node("/root/GameRoot/Dialog") # Reference to the dialog container

var setup_complete:bool # Setup finished

var LOADING:bool = false # Whether the game has loaded already or not
signal LOADING_FINISHED

### The initial configuration of the game when loaded.
var scene_space = "S1E01" # The folder where scenes are drawn from (the current episode).
export var game_beggining = {
	# The initial scene
	"first_scene": "Introduction",
	# The start character asset id
	"character": "ninten",
	# The initial zoom level
	"zoom": 1.2,
	# The initial battle music
	"battle_theme": "Twisted Battle.wav",
	# The initial background music
	"bgm": "Confrontation Anticipation.wav"
}

### Switches, variables that can be created and destroyed at any time for easy saving.
export var switches:Dictionary = {
	"player_name": "Player",
	"playtrough": 0,
	"section": 0,
}
### Quick switches
export var quick_switches:Dictionary = {}

#@ Setters and getters for switches
func check_switch(switch:String):
	return (switches.has(switch) and switches[switch]) or (quick_switches.has(switch) and quick_switches[switch])

func switch_exists(switch:String):
	return switches.has(switch)

func switch(switch:String, state=true):
	switches[switch] = state

func quick_switch(switch:String, state:bool=true):
	quick_switches[switch] = state

func clear_quick_switches():
	quick_switches = {}

##########

#
# @ Party and party settings
#

### The current character ID and node
var playable_character:String = "ninten"
var playable_character_node:Node2D

### If the main character is currently moving
var mainchar_moving:bool = false

### The main character position
var playable_character_position := Vector2.ZERO

### All the party member character IDs and nodes
export var party = [""]
var party_character_nodes = []

### The positions walked by the playable character that will be retraced by the party followers
onready var party_follower_path: Path2D

### All the characters present on the current map
var map_characters: Dictionary = {}



##########



#
# @  Setting up the game
#


func _ready():
	#get_tree().get_root().set_transparent_background(true)
	#OS.window_per_pixel_transparency_enabled = true
	
	### Setup is complete!
	if get_node("/root").has_node("GameRoot"):
		setup_complete = true
		game_running = true
	
	### Load the strings for my language
	DCCore.load_strings()
	
	### Boot the character system
	Utils.character_system_init()
	
	### Setup the streeam players!
	SoundtrackCore.setup_stream_players()
	
	### Setup useful variables
	if OS.has_environment("USERNAME"):
		DCCore.strings["player_name"] = OS.get_environment("USERNAME")
	else:
		DCCore.strings["player_name"] = "player"
	
	### If starting on the overworld, setup the overworld.
	if has_node("/root/GameRoot"):
		if overworld:
			setup_overworld()

#@ Setup the overworld, import the start scene and spawn the main character
func setup_overworld():
	world.remove_child(get_node("/root/GameRoot/World/Scene"))
	### Decide whether to load the first scene, or the scene played from the editor.
	
	# Create new scene and add it to the tree.
	var new_scene
	
	if ProjectSettings.get_setting("application/run/custom_first_scene") == "":
		Utils.async_load("res://assets/building_places/"+scene_space+"/"+game_beggining["first_scene"]+".tscn", {"id":"scene"})
	else:
		Utils.async_load(ProjectSettings.get_setting("application/run/custom_first_scene"), {"id":"scene"})
	new_scene = yield(Utils, "scene_loaded").instance
	
	LOADING = true
	
	### Let's create the main character!
	var ci:Character = Assets.get_asset(game_beggining.character)
	ci.get_parent().remove_child(ci)
	print(Assets.name)
	
	### Make it an ALLY
	ci.alignment = "ALLY"
	ci.load_options()
	ci.visible = true
	### At it to the tree
	
	world.add_child(new_scene)
	new_scene.name = "Scene"
	if not get_node("/root/GameRoot/World/Scene").has_node("3DObjects"):
		print("(!) Warning; not a valid room!")
		return
	get_node("/root/GameRoot/World/Scene/3DObjects").add_child(ci)
	
	### Set its name
	ci.name = ci.character_id
	Gameplay.party = []
	
	### Update the playable character
	playable_character = ci.character_id
	playable_character_node = ci
	map_characters[playable_character] = ci
	party_follower_path = get_node("/root/GameRoot/World/FollowerPath")
	party_follower_path.get_curve().set_point_position(0, ci.position)
	
	add_party_member(ci.character_id)
	
	### Update the zoom
	update_zoom_instant(game_beggining["zoom"])
	
	### Update inventory
	MenuCore.update_items()
	LOADING = false
	emit_signal("LOADING_FINISHED", {chara = ci})
	
	### Call the scene's special ready method if it has one
	if new_scene.has_method("scene_ready"):
		new_scene.scene_ready()
	
	BattleCore.setup_all()


##########


#
# @ Camera and camera settings
#

### The current zoom level
export var zoom = 1.0 setget update_zoom
var zoom_drag = 1.0

### Update the zoom, only when the game is perfecly set up.
func update_zoom(_zoom):
	zoom = _zoom

### Update the zoom, only when the game is perfecly set up.
func update_zoom_instant(_zoom):
	zoom = _zoom
	zoom_drag = zoom

var character_camera_offset = -16
var camera_position = Vector2.ZERO
func _process(_delta):
	# Camera
	if setup_complete:
		zoom_drag = lerp(zoom_drag, zoom, max(20 * _delta, 0.1))
		main_camera.zoom = Vector2(zoom_drag, zoom_drag)
	if overworld:
		match GAMEMODE:
			GM.OVERWORLD:
				if not LOADING and playable_character_node != null:
					character_camera_offset = - 16
					camera_position = playable_character_node.position + Vector2(0, character_camera_offset)
			GM.BATTLE:
				camera_position = lerp(
					BattleCore.battle.position, BattleCore.battlers[BattleCore.battle_turn].position, 0.2)
	if not DCCore.detached_camera:
		main_camera.position = camera_position

#
# @ Game Interaction Modes
#

var in_cutscene: bool = false
var in_event: bool = false
var in_dialog:bool = false
var in_ui: bool = false

# Game Mode
enum GM {
	OVERWORLD,
	BATTLE,
	BOSS,
	CUTSCENE
}
onready var GAMEMODE = GM.OVERWORLD



##########



#
# @ Party manipulation
#

func add_party_member(member):
	if not party.has(member):
		var c = map_characters[member]
		if not c == playable_character_node:
			c.get_node("CollisionShape2D").disabled = true
		c.is_party_member = true
		c.party_index = party.size()
		party.append(member)
		update_party()

func remove_party_member(member):
	if party.has(member):
		var c = map_characters[member]
		c.stop()
		c.get_node("CollisionShape2D").disabled = false
		c.is_party_member = false
		c.party_index = 0
		party.erase(member)
		update_party()

func update_party():
	party_character_nodes = []
	for i in party:
		party_character_nodes.append(map_characters[i])



##########


#
# @ Teleportation and switch between maps
#

### Warp between scenes or within a scene
func warp(scene:String, location:Vector2, transition="slide_black", angle=-1):
	Utils.async_load("res://assets/building_places/"+scene_space+"/"+scene+".tscn")
	warp_scene(
		yield(Utils, "scene_loaded").loader,
		location,
		transition,
		angle
	)

func warp_by_path(path:String, location:Vector2, transition="slide_black", angle=-1):
	Utils.async_load(path)
	warp_scene(
		yield(Utils, "scene_loaded").loader,
		location,
		transition,
		angle
	)

func warp_scene(scene:PackedScene, location:Vector2, transition="slide_black", angle=1):
	LOADING = true
	map_characters = {}
	party_follower_path.get_curve().clear_points()
	
	transition_player.play(transition)
	playable_character_node.enabled = false
	yield(transition_player, "animation_finished")
	
	for i in range(party_character_nodes.size()):
		var c:Node = party_character_nodes[i]
		if c.get_parent() != null:
			c.get_parent().remove_child(c)
	
	yield(get_tree().create_timer(0.25), "timeout")
	var new_scene = scene.instance()
	world.remove_child(get_node("/root/GameRoot/World/Scene"))
	new_scene.name = "Scene"
	world.add_child(new_scene)
	var w = new_scene.get_node("3DObjects")
	if w:
		for index in range(party_character_nodes.size()):
			var i = party_character_nodes[index]
			i.name = i.character_id
			#Add in the new character
			w.add_child(i)
			Gameplay.map_characters[i.character_id] = i
			i.position = location
			i.mv_target = i.position
			i.input_vector = Vector2.ZERO
			i.velocity = Vector2.ZERO
		if new_scene.has_method("scene_ready"):
			new_scene.scene_ready()
		main_camera.make_current()
		main_camera.position = playable_character_node.position
		party_follower_path.get_curve().clear_points()
		if not angle == -1:
			playable_character_node.angle = angle
		
		transition_player.play(transition+"_out")
		
		playable_character_node.update_reference()
		playable_character_node.enabled = true
	emit_signal("LOADING_FINISHED")
	emit_signal("warp_completed")
	LOADING = false

signal warp_completed

### Warp between scenes or within a scene
func teleport(location, transition="slide_black", angle=-1):
	var t = get_node("/root/GameRoot/Transition/TransitionPlayer")
	t.play(transition)
	playable_character_node.enabled = false
	yield(get_tree().create_timer(0.25), "timeout")
	for i in range(party_character_nodes.size()):
		party_character_nodes[i].mv_target = location
		party_character_nodes[i].position = location
	party_follower_path.get_curve().clear_points()
	main_camera.position = location - Vector2(0, 16)
	playable_character_node.enabled = true
	if not angle == -1:
		for c in Gameplay.party_character_nodes:
			c.angle = angle
	yield(get_tree().create_timer(0.25), "timeout")
	t.play(transition+"_out")
	#emit_signal("warp_completed")
	#emit_signal("LOADING_FINISHED")
