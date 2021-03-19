extends Node2D

var index: int = 0

func _process(_delta):
	if MenuCore.menu_open["item"]:
		index = clamp(index, 0, 4)
		for i in get_children():
			i.frame = 0
		if get_child_count() > 0:
			get_child(index).frame = 1
			if Input.is_action_just_pressed("ui_up"):
				index -= 1
				AudioManager.play_sound("SFX_Menu_Rotate")
			if Input.is_action_just_pressed("ui_down"):
				index += 1
				AudioManager.play_sound("SFX_Menu_Rotate")
