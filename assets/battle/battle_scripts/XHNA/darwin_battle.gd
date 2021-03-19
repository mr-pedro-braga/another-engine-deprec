extends Node

var next_pattern = "punches"
var next_pool = "general"
var aff = ""

func battle_join():
	Utils.change_battle_bg("Delta")
	pass

func battle_turn_select(c: Character, battle_round):
	if Gameplay.GAMEMODE != Gameplay.GM.BATTLE:
		return
	match battle_round:
		0:
			next_pool = "twistedhallways"
			DCCore.dialog("places/mrealm/mrealm_lines", "darwin_dodge")
			yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
			BattleCore.current_battle_line["dialog"] = "darwin_battle_1"
		1:
			DCCore.dialog("places/mrealm/mrealm_lines", "darwin_attackme")
			yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
			BattleCore.current_battle_line["dialog"] = "darwin_battle_2"
		2:
			next_pattern = "lasso"
			BattleCore.current_battle_line["dialog"] = "darwin_battle_3"
		_:
			if Utils.stats["darwin"]["attributes"]["HP"] < 6:
				if Gameplay.GAMEMODE != Gameplay.GM.BATTLE or spared:
					return
				match advice:
					0:
						DCCore.dialog("places/mrealm/mrealm_lines", "darwin_spare_end")
						yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
					1:
						DCCore.dialog("places/mrealm/mrealm_lines", "darwin_spare_please")
						yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
				advice += 1
				next_pool = "general"
				next_pattern = "wait"
				BattleCore.current_battle_line["dialog"] = "darwin_sparing"
			else:
				randomize()
				var attacks = ["lasso", "punches", "radial_escape"]
				attacks.shuffle()
				next_pattern = (attacks[0])
				BattleCore.current_battle_line["dialog"] = "darwin_battle_3"
	BattleCore.next_attack_name = {"pool":next_pool, "id":next_pattern}
	yield(get_tree().create_timer(0.2), "timeout")
	BattleCore.end_turn_intro()

var advice = 0
var spared = false

func act(_user, act_name):
	print("Thinking about ", act_name)
	match act_name:
		"help":
			DCCore.dialog("places/mrealm/mrealm_lines", "claire_help")
			yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
			Utils.emit_signal("act_finished")
		"spare":
			if Utils.stats["darwin"]["attributes"]["HP"] < 6:
				Gameplay.map_characters[_user].fight_action = "act_yes"
				DCCore.dialog("places/mrealm/mrealm_lines", "darwin_spare")
				yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
				spared = true
				Utils.emit_signal("act_finished")
				BattleCore.end_battle()
				Gameplay.map_characters["darwin"].get_node("AnimationPlayer").play("Goodbye")
			else:
				DCCore.dialog("places/mrealm/mrealm_lines", "darwin_nospare")
				yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
				Utils.emit_signal("act_finished")
		_:
			yield(get_tree().create_timer(1.0), "timeout")
			Utils.emit_signal("act_finished")
	pass
