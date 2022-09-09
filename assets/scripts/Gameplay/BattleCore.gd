extends Node

# Battle and battle settings
onready var battle = get_node("/root/GameRoot/WorldUI/Battle")
var battle_turn: int = 0
var turns_per_round: int = 0
var battle_target = ""
var battle_round: int = 0
var battlers: Array = []
var allies: Array = []
var opponents: Array = []
var inverted:= false
var camera_focus
onready var dialog = get_node("/root/GameRoot/Dialog")
signal turn_intro_finished
signal battle_finished
func end_turn_intro():
	emit_signal("turn_intro_finished")

var battle_board_anim_out

### Change the background animation!
func bg_anim (anim):
	match anim:
		"battle_start":
			AudioManager.play("SFX_UT_BattleStart")
			get_node("/root/GameRoot/HUD2/BgAnim").play("battle_start")
			yield(get_node("/root/GameRoot/HUD2/BgAnim"), "animation_finished")
			SoundtrackCore.battle_m_player.playing = true
			yield(Utils, "hot_second")
			for c in Gameplay.party:
				var info = BattleCore.info_container.get_node(c)
				info.reveal()
		"darken":
			get_node("/root/GameRoot/HUD2/BgAnim").play("darken")
		"clear":
			get_node("/root/GameRoot/HUD2/BgAnim").play("clear")

### Transpose all battlers to the battle layer
var transposed := false
func transpose_characters(characters):
	var _center = Vector2.ZERO
	for b in characters:
		_center += b.position
	_center /= characters.size()
	for i in range(characters.size()):
		var b = characters[i]
		b.load_options()
		b.world_parent = b.get_parent()
		b.world_position = b.position
		b.get_parent().remove_child(b)
		get_node("/root/GameRoot/BattleChars").add_child(b)
	transposed = true

### Make all characters face the center
func rc_chars(characters):
	for i in characters:
		i.face_center()

### Put all battlers in their original parents
func return_characters(characters):
	for b in characters:
		b.scale.x =  abs(b.scale.x)
		b.get_parent().remove_child(b)
		b.world_parent.add_child(b)
	transposed = false

func battle_start_animation():
	Gameplay.main_camera.smoothing_enabled = true
	get_node("/root/GameRoot/HUD/black_bars").play("battle_slide_in")
	get_node("/root/GameRoot/HUD/black_bars_top").play("menu_in")

# Call using 'battle(opponents, use abstract background, enemies first)'
func request_battle(_opponents, bbg=false, surprise=false):
	
	var BattleBG = get_node("/root/GameRoot/HUD2/BattleBG")
	BattleBG.visible = false
	
	battle_start_animation()
	
	SoundtrackCore.bgm_pause()
	battle = get_node("/root/GameRoot/WorldUI/Battle")
	Gameplay.playable_character_node.velocity = Vector2.ZERO
	Gameplay.playable_character_node.input_vector = Vector2.ZERO
	Gameplay.GAMEMODE = Gameplay.GM.BATTLE
	opponents = []
	var allycenter=Vector2.ZERO
	var opponentcenter=Vector2.ZERO
	var map_characters = Gameplay.map_characters
	if surprise:
		for i in range(_opponents.size()):
			battlers.append(map_characters[_opponents[i]])
			opponents.append(map_characters[_opponents[i]])
			load_battle_script(map_characters[_opponents[i]])
			opponentcenter += (map_characters[_opponents[i]].position)
		for i in range(Gameplay.party.size()):
			battlers.append(map_characters[Gameplay.party[i]])
			allies.append(map_characters[Gameplay.party[i]])
			allycenter += (map_characters[Gameplay.party[i]].position)
	else:
		for i in range(Gameplay.party.size()):
			battlers.append(map_characters[Gameplay.party[i]])
			allies.append(map_characters[Gameplay.party[i]])
			allycenter += (map_characters[Gameplay.party[i]].position)
		for i in range(_opponents.size()):
			battlers.append(map_characters[_opponents[i]])
			opponents.append(map_characters[_opponents[i]])
			load_battle_script(map_characters[_opponents[i]])
			opponentcenter += (map_characters[_opponents[i]].position)
	allycenter/=Gameplay.party.size()
	opponentcenter/=_opponents.size()
	battle.position = 0.5 * (allycenter + opponentcenter) - Vector2(0, 16)
	rc_chars(battlers)
	for i in range(opponents.size()):
		opponents[i].get_node("battle_script").battle_join()
	# Load every ally's attacks, acts, spells and stats if not loaded yet
	turns_per_round = battlers.size()
	
	Utils.update_soul_meters()
	for info in info_container.get_children():
		info.reveal()
	
	if bbg:
		if not transposed:
			transpose_characters(battlers)
		bg_anim("battle_start")
		var center = 0.5 * (allycenter + opponentcenter)
		
		inverted = allycenter.x > center.x
		var invert = -1 if inverted else 1
		for index in range(Gameplay.party.size()):
			var i = Gameplay.party_character_nodes[index]
			Utils.slide_to(i, center + Vector2(-64 - 16 * index, 32 * (index-(Gameplay.party.size()-1)/2.0))  * Vector2(invert, 1.0), 3.0, AnimationInstance.mode.EASE_OUT)
		for index in range(opponents.size()):
			var i = opponents[index]
			index = float(index)
			Utils.slide_to(i, center + Vector2( 64 + 16 * index, 32 * (index-(opponents.size()-1)/2.0)) * Vector2(invert, 0.0), 3.0, AnimationInstance.mode.EASE_OUT)
		yield(get_tree().create_timer(0.9), "timeout")
		
		# Make the rest of the world invisible to save draw calls!
		Gameplay.world.get_node("Scene/3DObjects").visible = false
		
		battle_loop()
		return
	
	if not SoundtrackCore.battle_m_player.playing:
		SoundtrackCore.battle_m_player.playing = true
	
	if not transposed:
		transpose_characters(battlers)
	battle_loop()

func mix(b, a, p) -> float:
	return (a * p + b * (1 - p))

var current_battle_attacks
var current_battle_options = {}
var current_battle_line = {
	"file": "places/mrealm/mrealm_lines",
	"dialog": "darwin_battle_1"
}
var next_attack_name = {"pool":"general", "id":"circle-of-fire"}
var next_pattern = ""

### Load the battle script for an opponent
func load_battle_script (character):
	if character.has_node("battle_script"):
		return
	var battle_script = Node.new()
	battle_script.name = "battle_script"
	var script = load("res://assets/battle/battle_scripts/" + character.attacks)
	battle_script.set_script(script)
	battle_script.aff = character.character_id.to_lower()
	Utils.battle_scripts[character.character_id.to_lower()] = battle_script
	character.add_child(battle_script)

onready var info_container = get_node("/root/GameRoot/HUD/SoulInfos")

func battle_loop():
	# BATTLES!!!
	while(true):
		
		var turnch = battlers[battle_turn]
		if turnch in Gameplay.party_character_nodes:
			var skill = Utils.character_stats[turnch.character_id]["attributes"]["skill"]
			
			if true:#current_battle_line["dialog"] == "null":
				dialog.simple_choice(
					[DCCore.strings["act"], DCCore.strings[skill], DCCore.strings["attack"], DCCore.strings["item"]],
					["act", skill, "fight", "item"],
				-16, 0, 2)
			else:
				
				DCCore.load_dialog_into_cache(current_battle_line["file"])
				var question = DCCore.dialog_cache[current_battle_line["file"]][current_battle_line["dialog"]]
				
				dialog.simple_choice(
					[DCCore.strings["act"], DCCore.strings[skill], DCCore.strings["attack"], DCCore.strings["item"]],
					["act", skill, "fight", "item"],
				-16, 0, 2, question)
			
			yield(DCCore, "choice_finished")
			
			current_battle_options = Utils.character_stats[battlers[battle_turn].character_id]
			
			#Thinking animation
			Gameplay.map_characters[battlers[battle_turn].character_id].fight_action = "think"
			var choice_pos = 3 if inverted else 2
			
			match DCCore.choice_result:
				0:
					# Display and ask for which attack to execute!
					var display_names = []
					var icons = []
					var acts = current_battle_options["acts"]
					for j in range(acts.size()):
						display_names.append(DCCore.strings[acts[j]["id"]])
						icons.append(acts[j]["icon"])
					dialog.simple_choice(display_names, icons, -16, choice_pos, 2)
					yield(dialog, "dialog_section_finished")
					Utils.act(
						battlers[battle_turn].character_id,
						opponents[0].character_id,
						acts[DCCore.choice_result]["id"]
					)
					yield(Utils, "act_finished")
				1:
					# Display and ask for which skill to execute!
					var display_names = []
					var icons = []
					var attacks = current_battle_options["skills"]
					for j in range(attacks.size()):
						display_names.append(DCCore.strings[attacks[j]["id"]])
						icons.append(attacks[j]["icon"])
					dialog.simple_choice(display_names, icons, -16, choice_pos, 2)
					yield(dialog, "dialog_section_finished")
				2:
					# Display and ask for which attack to execute!
					var display_names = []
					var icons = []
					var attacks = current_battle_options["attacks"]
					for j in range(attacks.size()):
						display_names.append(DCCore.strings[attacks[j]["id"]])
						icons.append(attacks[j]["icon"])
					dialog.simple_choice(display_names, icons, -16, choice_pos, 2)
					yield(DCCore, "choice_finished")
					
					var targets = opponents
					dialog.simple_char_choice(targets, 1)
					yield(DCCore, "choice_finished")
					battle_target = targets[DCCore.choice_result]
					Utils.attack(battlers[battle_turn].character_id, battle_target, "general", "weak_punch")
					yield(Utils, "attack_finished")
				3:
					MenuCore.focused_menu = "item"
					MenuCore.set_open("item", true)
					MenuCore.show_hotbar()
					yield(dialog, "dialog_ok")
					MenuCore.set_open("item", false)
					AudioManager.play_sound("SFX_Menu_Select")
					MenuCore.hide_hotbar()
		else:
			# Give the Character and select the next attack
			var bs = Utils.battle_scripts[battlers[battle_turn].character_id.to_lower()]
			bs.battle_turn_select(battlers[battle_turn], battle_round)
			yield(self, "turn_intro_finished")
			if Gameplay.GAMEMODE == Gameplay.GM.OVERWORLD:
				break
			battle_target = Gameplay.party_character_nodes[int(rand_range(0.0, Gameplay.party.size()))]
			#var info = info_container.get_node(battle_target.character_id)
			if not next_attack_name["id"] == "null":
				Utils.attack(battlers[battle_turn], battle_target.character_id, next_attack_name["pool"], next_attack_name["id"])
				yield(Utils, "attack_finished")
		Gameplay.map_characters[battlers[battle_turn].character_id].fight_action = "idle"
		battle_turn += 1
		if battle_turn >= turns_per_round:
			battle_turn = 0
			battle_round += 1
		if Gameplay.GAMEMODE == Gameplay.GM.OVERWORLD:
			break

func end_battle():
	# Make the rest of the world visible again so yo[u can play.
	Gameplay.world.get_node("Scene/3DObjects").visible = false
	Gameplay.GAMEMODE = Gameplay.GM.OVERWORLD
	return_characters(battlers)
	battlers = []
	allies = []
	opponents = []
	battle.visible = false
	battle_turn = 0
	battle_round = 0
	get_node("/root/GameRoot/BGM").playing = true
	get_node("/root/GameRoot/BattleTheme").playing = false
	get_node("/root/GameRoot/HUD/black_bars_top").play("menu_out")
	get_node("/root/GameRoot/HUD/black_bars").play("battle_slide_out")
	get_node("/root/GameRoot/HUD2/BattleBG").visible = false
	bg_anim("clear")
	for info in info_container.get_children():
		info.hide()
	emit_signal("battle_finished")

var emitter_scene = load("res://assets/battle/battle_patterns/Emitter.tscn")

func setup_all():
	Utils.async_load("res://assets/battle/battle_patterns/Emitter.tscn")
	emitter_scene = yield(SceneLoader, "on_scene_loaded").instance

## Create an eitter from a JSON specification
func emitter_from(in_attack):
	var e = emitter_scene.duplicate()
	var data = in_attack["pattern"][0]
	if data.has("set_angle"):
		e.set_angle = data["set_angle"]
	e.emit = data["emit"]
	e.bullet_sprite = data["bullet_sprite"]
	e.rate = data["rate"]
	e.one_shot = data["one-shot"]
	e.random_offset = Vector2(data["random_offset"][0], data["random_offset"][1])
	e.bullet_bundle = data["bullet_count"]
	e.angle_offset_i = data["angle_offset"]
	e.radius_offset_i = data["radius_offset"]
	e.bullet_speed = data["speed"]
	e.bullet_speed_offset = data["speed_rand"]
	e.bullet_life = data["bullet_life"]
	e.life_time = data["timeout"]
	e.position = Vector2(data["dpos"][0], data["dpos"][1])
	e.rotation_degrees = data["rotation"]
	e.damage = in_attack["damage"]
	battle.add_child(e)
	battle_board_anim_out = in_attack["battle_box_out"]
