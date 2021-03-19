extends Node

# Minigame System

signal minigame_end

func minigame(scene):
	var obj = scene.instance()
	obj.name = "Minigame"
	get_node("/root/GameRoot/HUD/Overlay").add_child(obj)

func minigame_end():
	get_node("/root/GameRoot/HUD/Overlay").remove_child(get_node("/root/GameRoot/HUD/Overlay").get_node("Minigame"))
	emit_signal("minigame_end")
