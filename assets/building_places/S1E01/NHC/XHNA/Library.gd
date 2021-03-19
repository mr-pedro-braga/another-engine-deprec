extends DefaultScene

onready var camera = get_node("Camera2D")
onready var andy = get_node("3DObjects/Andy")
onready var bruno = get_node("3DObjects/bruno")

func evt_exit(_id, _parameter, _arguments):
	if not Gameplay.switches.has("joke_1"):
		DCCore.dialog("places/new_horizon/school_lines", "library_dont_leave")
		yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
	else:
		if Gameplay.switches["joke_1"]:
			Gameplay.warp(_parameter, _arguments[0], _arguments[1], _arguments[2])
		else:
			DCCore.dialog("places/new_horizon/school_lines", "library_leave_attack_1")
			yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
			andy.visible=false
			Gameplay.playable_character_node.visible=false
			Gameplay.warp(_parameter, _arguments[0], _arguments[1], _arguments[2])
	

func evt_andy(_id, _parameter, _arguments):
	if Gameplay.switches.has("joke_1"):
		return
	Utils.enter_event()
	Gameplay.switches["joke_1"] = false
	andy.action = "sit_look"
	DCCore.dialog("places/new_horizon/school_lines", "cutscene_2_4")
	yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
	Utils.leave_event()
	Gameplay.add_party_member("andy")

func evt_posters(_id, _parameter, _arguments):
	DCCore.dialog("places/new_horizon/school_lines", "library_poster")
	yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")

func evt_bruno(_id, _parameter, _arguments):
	if _arguments[0] == 0:
		_id.arguments[0] += 1
		DCCore.dialog("places/new_horizon/school_lines", "cutscene_2_5")
		yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
	else:
		DCCore.dialog("places/new_horizon/school_lines", "cutscene_2_6")
		yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")

export(String, "mus_syncopation.wav", "mus_earthbound2.wav") var bgm = "MOTHER/mus_shop.wav"

func _ready():
	if not Gameplay.switches.has("entered_library"):
		
		SoundtrackCore.preload_music("mus_vn_tension.wav")
		SoundtrackCore.load_music(bgm, "Syncopation")
		
		Gameplay.switches["entered_library"] = true
		Gameplay.switches["phase"] = 1
		
		Utils.enter_event()
		
		Assets.transition_player.play("set_black")
		var dialog_box = get_node("/root/GameRoot/HUD/bottom_black_bar/SpriteText")

		var k = dialog_box.rect_position.y

		bruno.route = []
		Gameplay.playable_character_node.route = []

		dialog_box.rect_position.y = -55
		DCCore.dialog("places/new_horizon/school_lines", "cutscene_2_1")
		yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")

		dialog_box.rect_position.y = -100
		DCCore.dialog("places/new_horizon/school_lines", "cutscene_2_2")
		yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")

		dialog_box.rect_position.y = k
		yield(get_tree().create_timer(1.0), "timeout")
		Assets.transition_player.play("set_clear")
		Gameplay.main_camera.clear_current()
		$Camera2D.make_current()
		bruno.angle = 5
		Gameplay.playable_character_node.angle = 6
		andy.action = "lamp"

		bruno = get_node("3DObjects/bruno")
		DCCore.dialog("places/new_horizon/school_lines", "cutscene_2_3")
		yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
		andy.action = "sit"

		Utils.leave_event()

func _process(_delta):
	camera.offset = Vector2(0, 0.5*(135 - get_node("/root/GameRoot/HUD/bottom_black_bar").position.y))
