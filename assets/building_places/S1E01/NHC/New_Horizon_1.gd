extends Node2D

func scene_ready():
	Gameplay.update_zoom(1.4)
	SoundtrackCore.load_music("mus_new_horizon_night.wav", "New Horizon")

func _process(delta):
	if Input.is_action_just_pressed("cheat"):
		SoundtrackCore.bgm_resume()

func evt_testevent(_id, _parameter, _arguments):
	DCCore.dialog("places/new_horizon/one_liners", "subspace")
	yield(get_node("/root/GameRoot/Dialog"), "dialog_section_finished")
	Gameplay.warp("NHC/XHNA/Hallways", Vector2(0, 64), "slide_black", 2)

# Runs a simple dialogue that will repeat again exactly the same when you call this function again.
func evt_simple_dialogue(_id, _parameter, _arguments):
	DCCore.dialog(_parameter, _arguments[0])
