extends Node

var text_speed_scale = 0.7
var text_speed = 0.03

var current_dialog = {}
var dialogs_folder = "res://assets/dialogs/"

var waiting_for_input = false

signal checkpoint(name)

signal dialog_ok
signal dialog_finished
signal dialog_section_finished
signal wait(level)

### Takes in a string and formats it so it breaks if a word is too long.
func format_wrap(string:String) -> String:
	var char_limit = 38 if true else 34
	
	var words:Array = string.split(" ")
	var char_count = 0
	var result = ""
	
	for word in words:
		char_count += Utils.format_special(word).length()
		if "\n" in word:
			char_count = 0
		if char_count > char_limit:
			result += "\n"
			char_count = 0
		char_count += 1
		result += word + " "
	print(result)
	return result.replacen("\n\n", "\n")

func format(string) -> String:
	var regex = RegEx.new()
	regex.compile("%(?<c>\\S*)%")
	var r = string
	for m in regex.search_all(string):
		r = regex.sub(string, DCCore.strings[m.get_string("c")])
	
	r = format_wrap(r)
	
	return r

func _process(_delta):
	if Input.is_action_just_pressed("ok"):
		emit_signal("dialog_ok")

var last_character_mroute = ""

func play(in_dialog, dialog_box, sub_id, is_master=true, level = 0):
	var dialog
	if is_master:
		dialog = in_dialog[sub_id]
	else:
		dialog = in_dialog
	dialog_box.get_node("continue").visible=false
	Gameplay.in_dialog = true
	for k in dialog:
		match k["type"]:
			"checkpoint":
				emit_signal("checkpoint", k["name"])
			"speech_delay":
				text_speed = k["amount"]
			"set_kuroi":
				dialog_box.text = ""
				DCCore.dialog_box = get_node("/root/GameRoot/HUD/bottom_black_bar/Kuroi")
				dialog_box = DCCore.dialog_box
			"set_latin":
				dialog_box.text = ""
				DCCore.dialog_box = get_node("/root/GameRoot/HUD/bottom_black_bar/SpriteText")
				dialog_box = DCCore.dialog_box
			"move":
				last_character_mroute = k["character"]
				Gameplay.map_characters[k["character"]].move_route(k["route"])
			"await":
				yield(Gameplay.map_characters[last_character_mroute], "route_finished")
			"pose":
				if k.has("angle"):
					var old_angle = Gameplay.map_characters[k["character"]].angle
					var new_angle = k["angle"]
					var d = abs(new_angle-old_angle)
					
					var pi4 = PI/4
					for i in range(d):
						var a = lerp_angle(old_angle*pi4, new_angle*pi4, (i+1)/d)/pi4
						Gameplay.map_characters[k["character"]].angle = a
						Gameplay.map_characters[k["character"]].update_animation()
						yield(get_tree().create_timer(0.05), "timeout")
				if k.has("action"):
					Gameplay.map_characters[k["character"]].action = k["action"]
				Gameplay.map_characters[k["character"]].update_animation()
			"wait":
				dialog_box.text = ""
				slide_faces_out()
				yield(get_tree().create_timer(k["amount"]), "timeout")
			"dialog":
				# Checks if the dialog gives any bust sprite
				if k.has("bust_left"):
					if k["bust_left"] == "none":
						if get_node("/root/GameRoot/HUD/LeftBust").on_screen:
							get_node("/root/GameRoot/HUD/LeftBust").on_screen = false
							get_node("/root/GameRoot/HUD/LeftBust/Anim").play_backwards("in_right")
					elif not get_node("/root/GameRoot/HUD/LeftBust").on_screen:
						get_node("/root/GameRoot/HUD/LeftBust").on_screen = true
						get_node("/root/GameRoot/HUD/LeftBust/Anim").play("in_right")
				if k.has("bust_right"):
					if k["bust_right"] == "none":
						if get_node("/root/GameRoot/HUD/RightBust").on_screen:
							get_node("/root/GameRoot/HUD/RightBust").on_screen = false
							get_node("/root/GameRoot/HUD/RightBust/Anim").play_backwards("in_right")
					elif not get_node("/root/GameRoot/HUD/RightBust").on_screen:
						get_node("/root/GameRoot/HUD/RightBust").on_screen = true
						get_node("/root/GameRoot/HUD/RightBust/Anim").play("in_right")
				
				# If the dialog gives a speaking character, update DCCore::speaking_character
				if k.has("character"):
					DCCore.speaking_character = k.character
				else:
					DCCore.speaking_character = ""
				
				# Fetch the portrait from Utils::character_spec
				var portrait_name = Utils.get_specs(k.character.to_lower()).portrait
				
				# Creates the face animation using the portrait at the specs, and appending the given expression
				var face_anim = "none" if portrait_name == "none" or k.expression == "" else portrait_name + "_" + k.expression
				
				var portrait = get_node("/root/GameRoot/HUD/Portrait")
				
				if face_anim == "none":
					if portrait.on_screen:
						portrait.on_screen = false
						get_node("/root/GameRoot/HUD/Portrait/Anim").play_backwards("in")
				elif not portrait.on_screen:
					portrait.on_screen = true
					get_node("/root/GameRoot/HUD/Portrait/Anim").play("in")
				# Play the damn animation
				if portrait.frames.has_animation(face_anim):
					portrait.animation = face_anim
				
				# Writes to the dialog box using a special prefix.
				write_to(dialog_box, "- " + format(k["content"]), "claire")
				yield(self, "dialog_finished")
				
				# Wait for confirmation (Chr_OK)
				waiting_for_input = true
				dialog_box.get_node("continue").visible=true
				yield(self, "dialog_ok")
				
				# Proceed to the next cutscene entry.
				waiting_for_input = false
				dialog_box.get_node("continue").visible=false
				pass
			"choice":
				if k.has("character"):
					DCCore.speaking_character = k.character
				if k.has("portrait"):
					var portrait = get_node("/root/GameRoot/HUD/Portrait")
					if not k.has("character"):
						DCCore.speaking_character = k["portrait"].split("_")[0]
					if k["portrait"] == "none":
						if portrait.on_screen:
							portrait.on_screen = false
							get_node("/root/GameRoot/HUD/Portrait/Anim").play_backwards("in")
					elif not portrait.on_screen:
						portrait.on_screen = true
						get_node("/root/GameRoot/HUD/Portrait/Anim").play("in")
					if portrait.frames.has_animation(k["portrait"]):
						portrait.animation = k["portrait"]
				else:
					if not k.has("character"):
						DCCore.speaking_character = ""
				write_to(dialog_box, format(k["question"]), k["speaker"])
				yield(self, "dialog_finished")
				
				# The choice part
				DCCore.choice(format(k["question"]), k["choices"], k["icons"], -16, dialog_box)
				var choice_accepted = yield(DCCore, "choice_finished")
				
				if choice_accepted:
					# In case there are answers, play the selected one.
					if k["answers"] != []:
						play(k["answers"][DCCore.choice_result], dialog_box, "", false, level + 1)
						while yield(self, "wait") != level + 1:
							pass
			"sfx":
				Gameplay.map_characters[k["character"]].get_node(k["name"]).play()
			"function":
				var scene = get_node("/root/GameRoot/World/Scene/")
				scene.call(k["name"])
			"soundtrack":
				match k["action"]:
					"pause":
						SoundtrackCore.bgm_pause()
					"resume":
						SoundtrackCore.bgm_resume()
					"restart":
						SoundtrackCore.bgm_resume()
			"shake":
				Gameplay.main_camera.shake(0.5, 15, 4)
	if is_master:
		Gameplay.in_dialog = false
		if not Gameplay.GAMEMODE == Gameplay.GM.BATTLE and not DCCore.in_cutscene and not MenuCore.in_mmenu:
			get_node("/root/GameRoot/HUD/black_bars").play("dialog_pop_out")
			get_node("/root/GameRoot/HUD/black_bars_top").play("menu_out")
		dialog_box.text = ""
		slide_faces_out()
	if level == 0:
		emit_signal("dialog_section_finished")
	else:
		emit_signal("wait", level)

func slide_faces_out():
	if get_node("/root/GameRoot/HUD/LeftBust").on_screen:
		get_node("/root/GameRoot/HUD/LeftBust").on_screen = false
		get_node("/root/GameRoot/HUD/LeftBust/Anim").play_backwards("in_right")
	if get_node("/root/GameRoot/HUD/RightBust").on_screen:
		get_node("/root/GameRoot/HUD/RightBust").on_screen = false
		get_node("/root/GameRoot/HUD/RightBust/Anim").play_backwards("in_right")
	if get_node("/root/GameRoot/HUD/Portrait").on_screen:
		get_node("/root/GameRoot/HUD/Portrait").on_screen = false
		get_node("/root/GameRoot/HUD/Portrait/Anim").play_backwards("in")

func playc(id, sub_id, choices, icons, offset, mode=0):
	#get_node("/root/GameRoot/HUD/black_bars2").play("menu_in")
	#get_node("/root/GameRoot/HUD/black_bars").play("dialog_pop_in")
	var dialog_box = DCCore.dialog_box
	if id != "":
		var file = File.new()
		file.open("res://assets/dialogs/" + DCCore.lang + "/" + id + ".json", file.READ)
		var text = file.get_as_text()
		var current_dialog = parse_json(text)
		file.close()
		var in_dialog = current_dialog
		var dialog = in_dialog[sub_id]
		dialog_box.get_node("continue").visible=false
		Gameplay.in_dialog = true
		if(dialog == []):
			emit_signal("dialog_section_finished")
			return
		var k = dialog[0]
		write_to(dialog_box, k["content"], k["speaker"])
		yield(self, "dialog_finished")
		waiting_for_input = true
		dialog_box.get_node("continue").visible=true
		DCCore.choice(k["content"], choices, icons, offset, dialog_box, mode)
	else:
		DCCore.choice("", choices, icons, offset, dialog_box, mode)
	yield(self, "dialog_ok")
	waiting_for_input = false
	dialog_box.get_node("continue").visible=false
	Gameplay.in_dialog = false
	#get_node("/root/GameRoot/HUD/black_bars").play("dialog_pop_out")
	#get_node("/root/GameRoot/HUD/black_bars2").play("menu_out")
	dialog_box.text = ""
	emit_signal("dialog_section_finished")


func simple_choice(choices, icons, offset, mode=0, text_pos=0, question="...?"):
	#get_node("/root/GameRoot/HUD/black_bars2").play("menu_in")
	#get_node("/root/GameRoot/HUD/black_bars").play("dialog_pop_in")
	var dialog_box = DCCore.dialog_box
	waiting_for_input = true
	DCCore.choice(question, choices, icons, offset, dialog_box, mode, text_pos)
	yield(DCCore, "choice_finished")
	waiting_for_input = false
	Gameplay.in_dialog = false
	#get_node("/root/GameRoot/HUD/black_bars").play("dialog_pop_out")
	#get_node("/root/GameRoot/HUD/black_bars2").play("menu_out")
	emit_signal("dialog_section_finished")

func simple_char_choice(chars, text_pos=0, question="On whom...?"):
	#get_node("/root/GameRoot/HUD/black_bars2").play("menu_in")
	#get_node("/root/GameRoot/HUD/black_bars").play("dialog_pop_in")
	var dialog_box = DCCore.dialog_box
	waiting_for_input = true
	DCCore.char_choice(question, chars, text_pos)
	yield(DCCore, "choice_finished")
	waiting_for_input = false
	Gameplay.in_dialog = false
	#get_node("/root/GameRoot/HUD/black_bars").play("dialog_pop_out")
	#get_node("/root/GameRoot/HUD/black_bars2").play("menu_out")
	dialog_box.text = ""
	emit_signal("dialog_section_finished")


var key_dialog_vars = {
	"OK": "Z",
	"BACK": "X",
	"A": "A",
	"B": "S",
	"I": "I"
}

#func format(string) -> String:
#	var joker = RegEx.new()
#	joker.compile("\\[(\\S*)\\]")

# Write something step by step in a dialog box
func write_to(dialog_box, content, voice):
	dialog_box.text = content
	dialog_box.visible_characters = 0
	
	var file = "/voices/"+voice+".wav"
	
	var special_chars = RegEx.new()
	special_chars.compile("¬C\\d\\d|¬W|¬S|¬T|¬N")
	
	var refined = special_chars.sub(dialog_box.text, "", true)
	
	get_node("/root/GameRoot/HUD/Portrait").playing = true
	if get_node("/root/GameRoot/HUD/Portrait").get_speed_scale() < 0.0:
		get_node("/root/GameRoot/HUD/Portrait").playing = false
	
	DCCore.is_writing = true
	
	for i in range(refined.length()):
		match refined[i]:
			"¹":
				break
			"^":
				dialog_box.get_node("continue").visible=true
				get_node("/root/GameRoot/HUD/Portrait").playing = false
				DCCore.is_writing = false
				get_node("/root/GameRoot/HUD/Portrait").frame = 0
				yield(self,"dialog_ok")
				dialog_box.get_node("continue").visible=false
				get_node("/root/GameRoot/HUD/Portrait").playing = true
				DCCore.is_writing = true
			"¢":
				get_node("/root/GameRoot/HUD/Portrait").playing = false
				DCCore.is_writing = false
				get_node("/root/GameRoot/HUD/Portrait").frame = 0
				if not Input.is_action_pressed("ff"):
					yield(get_tree().create_timer(0.2*text_speed_scale), "timeout")
				get_node("/root/GameRoot/HUD/Portrait").playing = true
				DCCore.is_writing = true
			_:
				if not Input.is_action_pressed("ff"):
					if not refined[i] in [" ", "*", "-"]:
						AudioManager.play_audio(0, dialog_box, file, -10)
					yield(get_tree().create_timer(text_speed*text_speed_scale), "timeout")
				dialog_box.visible_characters+=1
	DCCore.is_writing = false
	get_node("/root/GameRoot/HUD/Portrait").playing = false
	get_node("/root/GameRoot/HUD/Portrait").frame = 0
	yield(get_tree().create_timer(text_speed*text_speed_scale), "timeout")
	emit_signal("dialog_finished")

#WAIT FUNCTION

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


