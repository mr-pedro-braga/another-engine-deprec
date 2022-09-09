extends Node2D
class_name Choice

var dialog_box
var question: String = ""
var choice_index = 0
var choices_count = 4
var choices = ["act", "spell", "fight", "item"]
var choice_icons = ["act", "psi", "fight", "item"]
var text_pos = 0

enum {
	RADIAL,
	LIST_TOP,
	LIST_LEFT,
	LIST_RIGHT
}

var display = RADIAL
var nametagtxt
var nametagtexture

func init_icons():
	
	if Utils.is_narrating:
		Utils.speak("Choice: " + choices[fmod(choice_index,choices_count)], false)
	
	Assets.selected_choice_box.text = ""
	choices_count = choices.size()
	DCCore.in_choice = true
	choice_index=int(floor(choices_count/2)) if display != RADIAL else 0
	var selection_indicator = Sprite.new()
	selection_indicator.texture = load("res://assets/user_interface/choice_selected.png")
	
	var offset = 0
	
	match display:
		RADIAL:
			var circle = Sprite.new()
			circle.texture = load("res://assets/user_interface/choice_circle.png")
			circle.scale.y = 0.9
			circle.scale = circle.scale * 0.875
			add_child(circle)
			selection_indicator.position.y = -28*0.9
			if text_pos == 2:
				var nametag = Assets.choice_nametag.instance()
				nametagtxt = nametag.get_node("Text")
				nametagtexture = nametag.get_node("Texture")
				nametag.rect_position.x = 9
				selection_indicator.add_child(nametag)
		LIST_TOP:
			selection_indicator.position.y = -32*0.9
		LIST_LEFT:
			selection_indicator.position.x = -24
			if text_pos == 2:
				var nametag = Assets.choice_nametag.instance()
				nametagtxt = nametag.get_node("Text")
				nametagtexture = nametag.get_node("Texture")
				nametag.rect_position.x = 9
				selection_indicator.add_child(nametag)
				offset -= 24
		LIST_RIGHT:
			selection_indicator.position.x = 24
			if text_pos == 2:
				var nametag = Assets.choice_nametag.instance()
				nametagtxt = nametag.get_node("Text")
				nametagtexture = nametag.get_node("Texture")
				nametag.rect_position.x = -9
				nametag.get_node("Texture").rect_scale.x = -1
				nametag.get_node("Text").rect_position.x = -48
				selection_indicator.add_child(nametag)
				offset -= 24
	update_nametag(choices[choice_index%choices_count])
	selection_indicator.position.y += offset
	add_child(selection_indicator)
	var f = load("res://assets/user_interface/choices.tres")
	for i in range(choices_count):
		var a: = ChoiceIcon.new()
		a.frames = f
		a.play(choice_icons[i])
		a.angle = float(i+choice_index)/float(choices_count)*2*PI
		a.angle_drag = a.angle
		a.index = i
		a.coffset = offset
		add_child(a)

func update_nametag(text:String):
	if nametagtxt == null:
		return
	var v = text.length()*6
	nametagtxt.text = text
	nametagtexture.rect_size.x = max(48, v)

func _process(_delta):
	match text_pos:
		0:
			dialog_box.text = question
			Assets.selected_choice_box.text = choices[choice_index%choices_count]
			dialog_box.visible_characters = -1
		1:
			Assets.selected_choice_box.text = question
			Assets.selected_choice_box.visible_characters = -1
		2:
			Assets.selected_choice_box.text = question
			Assets.selected_choice_box.visible_characters = -1
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_down"):
		choice_index += 1
		AudioManager.play_sound("SFX_Menu_Rotate")
		SpeechSynth.stop()
		if Utils.is_narrating:
			Utils.speak(choices[choice_index%choices_count])
		update_nametag(choices[choice_index%choices_count])
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up"):
		choice_index -= 1
		AudioManager.play_sound("SFX_Menu_Rotate")
		SpeechSynth.stop()
		if Utils.is_narrating:
			Utils.speak(choices[choice_index%choices_count])
		update_nametag(choices[choice_index%choices_count])
	if Input.is_action_just_pressed("ok"):
		Assets.selected_choice_box.text = ""
		dialog_box.text = ""
		AudioManager.play_sound("SFX_Menu_Select")
		DCCore.choice_result = choice_index % choices_count
		get_parent().remove_child(self)
		DCCore.emit_signal("choice_selected")
		DCCore.emit_signal("choice_finished", true)
		queue_free()
