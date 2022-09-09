extends Node2D
class_name CharChoice

var question: String = ""
var choice_index = 0
var choices_chars:Array = []
var text_pos = 0

func _process(_delta):
	
	var selected_char:Character = choices_chars[choice_index%choices_chars.size()]
	
	match text_pos:
		0:
			DCCore.dialog_box.text = question
			Assets.selected_choice_box.text = selected_char.name
			DCCore.dialog_box.visible_characters = -1
		1:
			Assets.selected_choice_box.text = question
			Assets.selected_choice_box.visible_characters = -1
	
	selected_char.set_highlited(true)
	
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_down"):
		choice_index += 1
		AudioManager.play_sound("SFX_Menu_Rotate")
		selected_char.set_highlited(false)
		if Utils.is_narrating:
			Utils.speak(choice_index%choices_chars)
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up"):
		choice_index -= 1
		AudioManager.play_sound("SFX_Menu_Rotate")
		selected_char.set_highlited(false)
		if Utils.is_narrating:
			Utils.speak(choice_index%choices_chars)
	if Input.is_action_just_pressed("ok"):
		Assets.selected_choice_box.text = ""
		DCCore.dialog_box.text = ""
		AudioManager.play_sound("SFX_Menu_Select")
		selected_char.set_highlited(false)
		queue_free()
		DCCore.emit_signal("choice_selected")
		DCCore.emit_signal("choice_finished")
