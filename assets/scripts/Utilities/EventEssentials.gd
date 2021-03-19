extends Node
class_name EventEssentials

func evt_save(_id, _paremeter, _arguments):
	DCCore.enter_cutscene()
	DCCore.dialog("common", "save")
	yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
	DCCore.dialog("common", "save_confirm")
	yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
	DCCore.leave_cutscene()

func evt_testevent(_id, _parameter, _arguments):
	Gameplay.dialog(_parameter, _arguments[0])
	yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
	Gameplay.warp("NHC/New_Horizon_1", Vector2(0, 32), "slide_black", 2)

# Moves all characters to a specific spot in another map
func evt_warp(_id, _parameter, _arguments):
	if Gameplay.in_event:
		return
	SoundtrackCore.bgm_pause()
	Gameplay.warp(_parameter, _arguments[0], _arguments[1], _arguments[2])

# Simply moves all characters to a different spot in the same map.
func evt_pathway(_id, _parameter, _arguments):
	if Gameplay.in_event:
		return
	Utils.enter_event()
	Gameplay.teleport(_arguments[0], _arguments[1], _arguments[2])
	yield(get_tree().create_timer(1.0), "timeout")
	Utils.leave_event()

# Runs a simple dialogue that will repeat again exactly the same when you call this function again.
func evt_simple_dialogue(_id, _parameter, _arguments):
	Utils.enter_event()
	DCCore.dialog(_parameter, _arguments[0])
	yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
	Utils.leave_event()

# Runs a simple dialogue that will destroy itself after use once
func evt_once_dialogue(_id, _parameter, _arguments):
	Utils.enter_event()
	DCCore.dialog(_parameter, _arguments[0])
	yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
	_id.queue_free()
	Utils.leave_event()

# Requests a simple battle
func evt_quick_battle(_id, _parameter, _arguments):
	Utils.enter_event()
	BattleCore.request_battle(_arguments[0], true, _arguments[1])
	_id.queue_free()
	Utils.leave_event()
	pass

# Requests a simple battle
func evt_pretty_battle(_id, _parameter, _arguments):
	Utils.enter_event()
	BattleCore.request_battle(_arguments[0], false, _arguments[1])
	_id.queue_free()
	Utils.leave_event()
	pass
