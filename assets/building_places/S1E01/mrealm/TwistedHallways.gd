extends DefaultScene

func scene_ready():
	SoundtrackCore.load_music("mus_en_tension.wav", "Extremely Necessary Tension")
	SoundtrackCore.bgm_resume()
	SoundtrackCore.preload_music("mus_twisted_battle.wav")
	Gameplay.main_camera.zoom = Vector2(1.2, 1.2)
	pass

var claire

func _process(_delta):
	if Input.is_action_just_pressed("cheat"):
		Gameplay.playable_character_node.position = Vector2(-441, 333)

func evt_darwin(_id, _parameter, _arguments):
	Utils.load_attack_pool("general")
	Utils.load_attack_pool("twistedhallways")
	if not Gameplay.switches.has("darwin_1"):
		var darwin = get_node("3DObjects/Darwin")
		Gameplay.map_characters["darwin"] = darwin
		darwin.angle = 1
		Gameplay.in_event=true
		evt_simple_dialogue(null, "places/mrealm/mrealm_lines", ["darwin_encounter"])
		yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
		Gameplay.in_event=false
		Gameplay.main_camera.zoom=Vector2(1.0,1.0)
		SoundtrackCore.unload_music()
		BattleCore.request_battle(["darwin"], true, true)
		Gameplay.switches["darwin_1"] = true

func evt_light(_id, _parameter, _arguments):
	if Gameplay.switches.has("light_1_on"):
		Utils.enter_event()
		evt_simple_dialogue(null, "places/mrealm/mrealm_lines", ["light_switch_used"])
		yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
		Utils.leave_event()
	else:
		Utils.enter_event()
		evt_simple_dialogue(null, "places/mrealm/mrealm_lines", ["light_switch"])
		yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
		Utils.leave_event()
		get_node("Light/"+str(_parameter)).queue_free()
		Gameplay.switches["light_1_on"] = true
