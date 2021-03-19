extends YSort
class_name NodeCollection

export(String) var switch_name
export(String, "boolean", "cutscene", "exactly", "interval", "greater than min", "less than max") var type = "boolean"
export(int) var switch_min
export(int) var switch_max

func _ready():
	match type:
		"boolean":
			if Gameplay.switches.has(switch_name) and Gameplay.switches[switch_name]:
				pop_children()
			else:
				queue_free()
		"cutscene":
			if not Gameplay.switches.has(switch_name) and Gameplay.switches[switch_name] > switch_min and Gameplay.switches[switch_name] < switch_max:
				queue_free()
		"interval":
			if Gameplay.switches.has(switch_name) and Gameplay.switches[switch_name] > switch_min and Gameplay.switches[switch_name] < switch_max:
				pop_children()
			else:
				queue_free()
		"greater than min":
			if Gameplay.switches.has(switch_name) and Gameplay.switches[switch_name] > switch_min:
				pop_children()
			else:
				queue_free()
		"less than max":
			if Gameplay.switches.has(switch_name) and Gameplay.switches[switch_name] < switch_max:
				pop_children()
			else:
				queue_free()

func pop_children():
	pass
