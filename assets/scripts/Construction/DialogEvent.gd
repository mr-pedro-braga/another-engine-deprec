extends EventReference
class_name DialogEvent

#
# @ Dialog Events Class!
#
# Useful for setting up simple talking events with minimal setup.
#

export(String, FILE, "*.sson") var dialog_sson_file
export(Array, String) var dialog_keys

#@ The current dialog from the list
var dialog_index = 0

#@ If this dialog calls or activate some switch.
export(String) var switch = ""

# When this event gets activated
func _on_activated():
	Utils.enter_event()
	DCCore.dialog_by_file(dialog_sson_file, dialog_keys[dialog_index])
	yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
	Utils.leave_event()
	
	if switch != "":
		Gameplay.switches[switch] = true
	
	if dialog_index < dialog_keys.size() - 1:
		dialog_index += 1
