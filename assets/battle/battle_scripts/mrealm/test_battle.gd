extends Node

var end = false
var spared = false
var aff = ""

func battle_join():
	
	spared = false
	Utils.change_battle_bg("Citrus")
	Utils.stats[Gameplay.playable_character]["acts"] = [
		{"id" : "bad_talk", "icon" : "talk_bad"},
		{"id" : "spare", "icon" : "spare"},
		{"id" : "hug", "icon" : "wait"},
	]
	DCCore.load_dialog_into_cache("places/new_horizon/school_lines")
	BattleCore.current_battle_line["file"] = "places/new_horizon/school_lines"
	BattleCore.current_battle_line["dialog"] = "null"

func battle_turn_select(c: Character, battle_round):
	if Gameplay.GAMEMODE != Gameplay.GM.BATTLE:
		return
	randomize()
	
	if end:
		BattleCore.end_battle()
		queue_free()
		return
	
	BattleCore.current_battle_line["file"] = "places/new_horizon/school_lines"
	BattleCore.current_battle_line["dialog"] = "andy_battle_comment"
	
	var attacks = Utils.stats[c.character_id]["attacks"]
	BattleCore.next_attack_name = attacks[(fposmod(battle_round, attacks.size()))]
	yield(get_tree().create_timer(0.1), "timeout")
	
	# Battle actions
	
	match BattleCore.battle_round:
		1:
			DCCore.dialog("test_dialog", "andy_battle_1")
			yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
	
	
	BattleCore.end_turn_intro()

func act(_user, act_name):
	match act_name:
		"spare":
			Gameplay.map_characters[_user].fight_action = "act_yes"
			if not spared:
				DCCore.dialog("places/new_horizon/school_lines", "andy_battle_nospare")
				yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
				Gameplay.map_characters[_user].fight_action = "idle"
			else:
				DCCore.dialog("places/new_horizon/school_lines", "andy_battle_spare")
				yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
				end = true
			Utils.emit_signal("act_finished")
		_:
			yield(get_tree().create_timer(1.0), "timeout")
			Utils.emit_signal("act_finished")
