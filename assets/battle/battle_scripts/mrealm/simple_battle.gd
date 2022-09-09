extends Node

var spared = false
var advice = 0
var aff = ""

func battle_join():
	pass

func battle_turn_select(c: Character, battle_round):
	if Gameplay.GAMEMODE != Gameplay.GM.BATTLE:
		return
	randomize()
	if not Utils.character_stats.has(c.character_id):
		print("Character info not loaded into stats!")
		BattleCore.end_turn_intro()
		return
	var attacks = Utils.character_stats[c.character_id]["attacks"]
	attacks.shuffle()
	BattleCore.current_battle_line["dialog"] = "darwin_battle_3"
	BattleCore.next_attack_name = (attacks[0])
	yield(get_tree().create_timer(0.2), "timeout")
	BattleCore.end_turn_intro()

func act(_user, act_name):
	print("Thinking about ", act_name)
	match act_name:
		_:
			yield(get_tree().create_timer(1.0), "timeout")
			Utils.emit_signal("act_finished")
	pass
