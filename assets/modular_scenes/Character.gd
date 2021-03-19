tool
extends KinematicBody2D
class_name Character

# Character ID for movements and such. #
var world_position
var world_parent
export var in_cutscene = false
export var character_id = "claire"
export var local_instance_id = 0
export var update_actions = true
export(String, "ALLY", "OPPONENT") var alignment = "OPPONENT"
var enabled = true
export var action = "idle"

# Movement Variables #
var ignoring_inputs = true
var velocity:Vector2 = Vector2.ZERO
var is_running:bool = false
var run_pressed:bool = false
var ACCELERATION = 512
var FRICTION = 512
var MAX_SPEED = 64
var MXSM = 1
var input_vector = Vector2.ZERO
var last_input_vector = Vector2.DOWN
var lock_angle = false

var fight_action = "idle"

export var lock_animation = false
export var locked_animation = ""

var target:Vector2

export var attacks = ""
export var char_stats_file = "claire.attacks"

export var angle = 2
export var Z = 0

func load_options():
	world_parent = get_parent()
	match alignment:
		"ALLY":
			if not Utils.character_stats.has(character_id):
				var file = File.new()
				file.open("res://assets/battle/party_member_stats/" + char_stats_file, File.READ)
				var text = file.get_as_text()
				Utils.character_stats[character_id] = parse_json(text)
				
		"OPPONENT":
			if not Utils.character_stats.has(character_id):
				var file = File.new()
				file.open("res://assets/battle/battle_scripts/" + char_stats_file, File.READ)
				var text = file.get_as_text()
				Utils.character_stats[character_id] = parse_json(text)

func face_center():
	if position.x < BattleCore.battle.position.x:
		scale.x = -abs(scale.x)
	else:
		scale.x =  abs(scale.x)

func _ready():
	if Gameplay.LOADING:
		yield(Gameplay, "LOADING_FINISHED")
	Gameplay.map_characters[character_id] = self
	ignoring_inputs = false
	if not Engine.editor_hint and character_id == Gameplay.playable_character:
		Gameplay.playable_character_node = self

func update_reference():
	Gameplay.map_characters[character_id] = self

# Events #
func _process(_delta):
	var a = angle * 45
	get_node("RayCast2D").cast_to = 10 * Vector2(cos(deg2rad(a))*1.5, sin(deg2rad(a)))
	if Engine.editor_hint:
		return
	
	### If this character is the main character, leave a trail of positions for the party followers
	if character_id == Gameplay.playable_character:
		if in_route or velocity.length() > 0.0:
			Gameplay.add_follower_point(position)
	
	### If this character is speaking, update its animation to be speaking, if possible
	if character_id == DCCore.speaking_character:
		update_anim_talk()
	if not Gameplay.GAMEMODE == Gameplay.GM.OVERWORLD or Gameplay.in_event or Gameplay.in_ui or Gameplay.in_dialog or Gameplay.in_cutscene or not enabled:
		ignoring_inputs = true
	else:
		ignoring_inputs = false
	

# Physics #
func _physics_process(delta):
	if not Engine.editor_hint:
		# Movement
		if not (ignoring_inputs):
			if character_id == Gameplay.playable_character:
				if not in_route:
					input_vector = Vector2(
						Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
						Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
					)
				if (Gameplay.in_event or Gameplay.in_ui or Gameplay.in_dialog):
					stop()
			elif Gameplay.party.has(character_id):
				if not (Gameplay.in_ui or Gameplay.in_dialog or Gameplay.in_event or Gameplay.GAMEMODE == Gameplay.GM.BATTLE):
					var index = Gameplay.party.find(character_id)
					update_party_pos(index, delta)
					MXSM = Gameplay.playable_character_node.MXSM
					if (target - get_position()).length() > 2 and (target - Gameplay.playable_character_position).length() > 16:
						input_vector = (target - get_position())
						#position = lerp(position, target, 0.5)
					else:
						stop()
				else:
					stop()
			$CollisionShape2D.disabled = Gameplay.party.has(character_id) and not character_id == Gameplay.playable_character
			input_vector = input_vector.normalized() if input_vector != Vector2.ZERO else Vector2.ZERO
		if input_vector != Vector2.ZERO and not run_pressed:
			last_input_vector = input_vector
			velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, min(FRICTION * delta, velocity.length()))
		if in_route:
			process_route(delta)
		if enabled and not Gameplay.GAMEMODE == Gameplay.GM.BATTLE:
			move_and_slide(velocity)
		if not in_cutscene:
			if Gameplay.party.has(character_id) and not Gameplay.in_event:
				# Actions
				if !Input.is_action_pressed("run"):
					run_pressed = false
				if Input.is_action_pressed("run"):
					if not run_pressed:
						run_pressed = true
						MAX_SPEED = 128*MXSM
						is_running = !is_running
						velocity = Vector2.ZERO
				elif is_running:
					velocity = MAX_SPEED * last_input_vector
				elif Input.is_action_pressed("sneak"):
					MAX_SPEED = 32*MXSM
				else:
					MAX_SPEED = 64*MXSM
			
			if update_actions and character_id == Gameplay.party[0]:
				if velocity.length() > 1.0:
					action = "run" if is_running and Gameplay.party.has(character_id) else "walk"
					Gameplay.mainchar_moving = true
					Gameplay.playable_character_position = get_position()
				elif in_path:
					action = "walk"
				elif action in ["run_charge", "idle", "run", "walk"]:
					action = "run_charge" if run_pressed and Gameplay.party.has(character_id) else "idle"
					Gameplay.mainchar_moving = false
			if update_actions and Gameplay.party.has(character_id):
				if velocity.length()!=0.0 or in_path:
					action = "run" if is_running else "walk"
				elif in_path:
					action = "walk"
				elif action in ["run_charge", "idle", "run", "walk"]:
					action = "run_charge" if run_pressed  else "idle"
		if not lock_angle and input_vector != Vector2.ZERO:
			angle = round((Vector2.RIGHT.angle_to(velocity) / (2*PI)) * 8)
	var anim = ""
	if Engine.editor_hint:
		anim = action + "_" + str(fposmod(angle,8))
		if lock_animation:
			anim = locked_animation
		$AnimatedSprite.position.y = -15-Z
		update_anim(anim)
		return
	match Gameplay.GAMEMODE:
			Gameplay.GM.OVERWORLD:
				anim = action + "_" + str(fposmod(angle,8))
			Gameplay.GM.BATTLE:
				anim = "fight_" + fight_action
	if lock_animation:
		anim = locked_animation
	$AnimatedSprite.position.y = -15-Z
	update_anim(anim)

func update_animation():
	var anim = ""
	match Gameplay.GAMEMODE:
		Gameplay.GM.OVERWORLD:
			anim = action + "_" + str(fposmod(angle,8))
		Gameplay.GM.BATTLE:
			anim = "fight_" + fight_action
	update_anim(anim)

func stop():
	is_running = false
	target = position
	input_vector = Vector2.ZERO
	velocity = Vector2.ZERO

# Updates the position, for party followers.
func update_party_pos(_i, delta):
	if Gameplay.in_dialog:
		return
	#print(1/(delta*60))
	var i = _i * 24 / (delta*60)
	if not Gameplay.party_follower_positions.empty():
		target = Gameplay.party_follower_positions[-i] if i < Gameplay.party_follower_positions.size() else Gameplay.party_follower_positions[0]

### Movement Routes! ###
# They are kind of like animations, but by programming.

## Commands: ##

# absolute:	[X, Y]
# pathfind:	[X, Y]
# delta: 	[X, Y]
# dir:		<angle>
# anim:		<anim>
# wait:		<seconds>
# dialog:	<file> <block>
# path:		<path>

var in_route:bool
var in_path:bool
export(Array, Dictionary) var route = [
]

func move_route(mroute):
	if mroute != []:
		route = mroute
		play_route()

func move_along(path:Path2D):
	route = []
	path.curve.set_point_position(0, position)
	path.get_child(0).offset=0
	route.append({"type":"path", "path":path})
	Gameplay.add_follower_point(position)
	in_route = true
	play_route()

signal route_line_finished
signal route_finished
var route_index = 0

func play_route():
	in_route = true
	c_route_instruction = {}
	route_index = 0
	t = 0
	p0 = Vector2.ZERO
	started = false
	input_vector = Vector2.ZERO
	while route_index < route.size():
		play_route_line(route[route_index])
		route_index+=1
		yield(self, "route_line_finished")
	route = {}
	MAX_SPEED = 64
	c_route_instruction = {}
	emit_signal("route_finished")
	EventBus.emit_signal("character_route_finished")
	in_route = false
	in_path = false

var c_route_instruction = {}
var EPSILON = 0.1

func play_route_line(instruction):
	c_route_instruction = instruction

var t = 0
var p0 = Vector2.ZERO
var started
var path:Path2D
var poff:PathFollow2D
func process_route(delta):
	var backup = c_route_instruction
	match c_route_instruction["type"]:
		"speed":
			MAX_SPEED = c_route_instruction["value"]
			emit_signal("route_line_finished")
		"goto":
			route_index = c_route_instruction["line"]
			emit_signal("route_line_finished")
		"lock_angle":
			lock_angle = true
			emit_signal("route_line_finished")
		"unlock_angle":
			lock_angle = false
			emit_signal("route_line_finished")
		"append_path":
			path = c_route_instruction["path"]
			path.curve.set_point_position(0, position)
			path.get_child(0).offset=0
			emit_signal("route_line_finished")
		"path":
			if not started:
				in_path = true
				started = true
				path = c_route_instruction["path"]
				poff = path.get_child(0)
			poff.offset += MAX_SPEED * delta
			action = "walk"
			position = poff.position
			angle = int(round((fposmod(poff.rotation_degrees/45, 8))))
			if poff.unit_offset >= 1:
				emit_signal("route_line_finished")
				started=false
				in_path = false
		"absolute":
			if not started:
				p0 = position
				started = true
			t+=delta
			var t2 = Vector2(c_route_instruction["target"][0], c_route_instruction["target"][1])
			input_vector = (t2 - p0).normalized()
			velocity = input_vector * MAX_SPEED
			if t >= p0.distance_to(t2)/MAX_SPEED:
				input_vector = Vector2.ZERO
				velocity = Vector2.ZERO
				t=0
				started=false
				emit_signal("route_line_finished")
		"delta":
			if not started:
				p0 = position
				started = true
			t+=delta
			var t2 = Vector2(c_route_instruction["target"][0], c_route_instruction["target"][1])
			var ttt = p0 + t2
			input_vector = (ttt - p0).normalized()
			velocity = input_vector * MAX_SPEED
			if t >= p0.distance_to(ttt)/MAX_SPEED:
				input_vector = Vector2.ZERO
				velocity = Vector2.ZERO
				t=0
				started=false
				emit_signal("route_line_finished")
		"dialog":
			Gameplay.dialog(c_route_instruction["file"], c_route_instruction["block"])
			yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
			emit_signal("route_line_finished")
		"wait":
			if not started:
				t=0
				started = true
			t+=delta
			if t>=backup["amount"]:
				t=0
				started=false
				emit_signal("route_line_finished")
		"anim":
			$AnimationPlayer.play(c_route_instruction["name"])
			emit_signal("route_line_finished")
		"action":
			action = c_route_instruction["action"]
			var anim = action + "_" + str(fposmod(angle,8))
			if lock_animation:
				anim = locked_animation
			$AnimatedSprite.position.y = -15-Z
			update_anim(anim)
			emit_signal("route_line_finished")
		"dir":
			angle = c_route_instruction["angle"]
			var anim = action + "_" + str(fposmod((angle),8))
			update_anim(anim)
			emit_signal("route_line_finished")
		"destroy":
			emit_signal("route_line_finished")
			emit_signal("route_finished")
			queue_free()

func update_anim(anim):
	if $AnimatedSprite.frames.has_animation(anim) and $AnimatedSprite.animation!=anim and $AnimatedSprite.animation!=anim+"_talk":
		$AnimatedSprite.play(anim)

func update_anim_talk():
	if Engine.editor_hint:
		return
	var playing_anim = $AnimatedSprite.animation
	var a = ""
	if DCCore.is_writing:
		a = playing_anim.replace("_talk", "") + "_talk"
	else:
		a = playing_anim.replace("_talk", "")
	if $AnimatedSprite.frames.has_animation(a) and $AnimatedSprite.animation != a:
		$AnimatedSprite.play(a)

func set_soul_mean(k):
	$AnimatedSprite.material.set_shader_param("soul_mean", k)

func set_highlited(k):
	$AnimatedSprite.material.set_shader_param("highlight", k)
