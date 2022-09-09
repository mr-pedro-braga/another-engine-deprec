extends EventEssentials

onready var start = get_node("Start")

func scene_ready():
	Utils.load_attack_pool("general")
	Utils.load_attack_pool("twistedhallways")
	var battle_player: AudioStreamPlayer = get_node("/root/GameRoot/BattleTheme")
	battle_player.stream = SoundtrackCore.test_music
	Gameplay.update_zoom(1.4)
	
	DCCore.load_dialog_script("test_dialog")
	#$Camera2D.make_current()

var p_count = 0

func _process(delta):
	return
	if not Gameplay.in_event and Gameplay.GAMEMODE != Gameplay.GM.BATTLE and Input.is_action_just_pressed("cheat"):
		DCCore.enter_cutscene()
		BattleCore.dialog.playc("", "",
			[
				"Fight Lily",
				"Summon Bruno",
				"Start Music",
				"Test Games"
			],
			["fight", "ch_bruno", "act", "game"],
				-16, 0)
		yield(BattleCore.dialog, "dialog_section_finished")
		DCCore.leave_cutscene()
		match DCCore.choice_result:
			0:
				BattleCore.request_battle(["lily"], true, false)
			2:
				SoundtrackCore.load_music("mus_new_horizon.wav", "New Horizon")
				SoundtrackCore.bgm_resume()
			3:
				Gameplay.add_party_member("Andy")
			_:
				pass
