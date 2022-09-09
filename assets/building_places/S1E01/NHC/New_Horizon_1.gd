extends Node2D

func scene_ready():
	Gameplay.update_zoom(1.4)
	SoundtrackCore.load_music("mus_new_horizon.wav", "New Horizon")
	#SoundtrackCore.bgm_resume()

func _process(delta):
	if not Gameplay.in_event and Gameplay.GAMEMODE != Gameplay.GM.BATTLE and Input.is_action_just_pressed("cheat"):
		DCCore.enter_cutscene()
		BattleCore.dialog.playc("", "",
			[
				"Fight Lily",
				"Get Food Items!",
				"Start Music",
				"Test Games"
			],
			["fight", "ch_bruno", "act", "game"],
				-16, 0)
		yield(BattleCore.dialog, "dialog_section_finished")
		DCCore.leave_cutscene()
		match DCCore.choice_result:
			0:
				Gameplay.update_zoom(1.0)
				BattleCore.request_battle(["lily"], true, true)
			2:
				pass
			3:
				Gameplay.add_party_member("andy")
				Gameplay.add_party_member("lily")
			_:
				print("Cheated")
				MenuCore.inventories["claire"].give_item("pepperoni_pizza", 3)
				MenuCore.inventories["claire"].give_item("paçoca", 4)
				MenuCore.inventories["claire"].give_item("mana_pop", 1)
				MenuCore.inventories["claire"].give_item("flame_chips", 2)
				MenuCore.inventories["claire"].give_item("burger", 4)
				#Gameplay.warp("ClioRoom", Vector2(0.0, 0.0))
				#SoundtrackCore.bgm_restart()

func evt_testevent(_id, _parameter, _arguments):
	DCCore.dialog("places/new_horizon/one_liners", "subspace")
	yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
	Gameplay.warp("NHC/XHNA/Hallways", Vector2(0, 64), "slide_black", 2)

# Runs a simple dialogue that will repeat again exactly the same when you call this function again.
func evt_simple_dialogue(_id, _parameter, _arguments):
	DCCore.dialog(_parameter, _arguments[0])
