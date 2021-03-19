extends Node

var spared = false
var flirt_level = 0
var aff = ""

func battle_join():
	Utils.change_battle_bg("Delta")
	Utils.stats["claire"]["acts"] = [
		{"id" : "pose", "icon" : "pose"},
		{"id" : "spare", "icon" : "spare"},
		{"id" : "flirt", "icon" : "flirt"}
	]

func battle_turn_select(c: Character, battle_round):
	if Gameplay.GAMEMODE != Gameplay.GM.BATTLE:
		return
	randomize()
	
	BattleCore.current_battle_line["file"] = "places/mrealm/tschool_lines"
	BattleCore.current_battle_line["dialog"] = "ashley_comment_" + str( min(BattleCore.battle_round, 3) )
	if BattleCore.battle_round < 14:
		DCCore.dialog("places/mrealm/tschool_lines", "ashley_convo_" + str( min(BattleCore.battle_round, 13) ))
		yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
	
	var attacks = Utils.stats[c.character_id]["attacks"]
	BattleCore.next_attack_name = attacks[(fposmod(battle_round, attacks.size()))]
	yield(get_tree().create_timer(0.2), "timeout")
	BattleCore.emit_signal("turn_intro_finished")

func act(_user, act_name):
	match act_name:
		"pose":
			if not spared:
				DCCore.dialog("places/mrealm/tschool_lines", "ashley_pose")
				yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
		"spare":
			if not spared:
				DCCore.dialog("places/mrealm/tschool_lines", "ashley_nospare")
				yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
			else:
				DCCore.dialog("places/mrealm/tschool_lines", "ashley_spare")
				yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
			Utils.emit_signal("act_finished")
		"flirt":
			if flirt_level <= 3:
				DCCore.dialog("places/mrealm/tschool_lines", "ashley_flirt_" + str(flirt_level))
				yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
				flirt_level += 1
			else:
				DCCore.dialog("places/mrealm/tschool_lines", "ashley_flirt_no")
				yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
			Utils.emit_signal("act_finished")
		_:
			yield(get_tree().create_timer(1.0), "timeout")
			Utils.emit_signal("act_finished")
	pass
