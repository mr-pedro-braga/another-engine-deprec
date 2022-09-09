extends Node

#
#
#	Handles the entire system for dialogs, choices and
#	cutscene-related things like cameras and signals.
#
#

### The current language of the game
export(String, "pt-br", "en") var lang:String = "en"

### The dialog box used to display the dialog
onready var dialog_box = get_node("/root/GameRoot/HUD/bottom_black_bar/SpriteText")

### Useful UI strings
var strings:Dictionary = {}
### Dialog cache
var dialog_cache:Dictionary = {}
### Is currently writing some dialog
var is_writing:bool = false setget update_speaking_character_anim
### If in camera_beding_cutscene
var in_cutscene = false
var detached_camera = false

var speaking_character:String = "" 
func update_speaking_character_anim(value):
	is_writing = value
	if !Gameplay.map_characters:
		return
	if Gameplay.map_characters.has(speaking_character):
		Gameplay.map_characters[speaking_character].update_anim_talk()

### Request Dialog from file!
func dialog_by_file(file:String, sub_id:String):
	dialog(file.replace("res://assets/dialogs/" + "en" + "/", "").replace(".sson", ""), sub_id)

### Request Dialog from id.
func dialog(id, sub_id):
	#get_node("/root/GameRoot/HUD/black_bars2").play("menu_in")
	if not Gameplay.GAMEMODE == Gameplay.GM.BATTLE and not in_cutscene and not MenuCore.in_mmenu:
		get_node("/root/GameRoot/HUD/black_bars").play("dialog_pop_in")
		get_node("/root/GameRoot/HUD/black_bars_top").play("menu_in")
	if Gameplay.playable_character_node:
		Gameplay.playable_character_node.velocity = Vector2.ZERO
		Gameplay.playable_character_node.input_vector = Vector2.ZERO
	load_dialog_script(id)
	
	get_node("/root/GameRoot/Dialog").play(dialog_cache[id], dialog_box, sub_id, true)

### Loads a whole dialog file into cache so you have to load only once
func load_dialog_into_cache(file):
	if dialog_cache.has(file):
		return
	var text = Utils.load_as_text("res://assets/dialogs/" + lang + "/" + file + ".json")
	dialog_cache[file] = parse_json(text)

###	Loads a ScreenScript file and parses it into Chroma RPG Alpha
#	compatible format!
func load_dialog_script(file):
	if dialog_cache.has(file):
		return
	var text = Utils.load_as_text("res://assets/dialogs/" + lang + "/" + file + ".sson")
	
	dialog_cache[file] = SceneScript.parse_sson_cutscene(text)

### Clears the dialog cache to save memory
func clear_dialog_cache():
	dialog_cache = {}

### Loads useful UI strings
func load_strings():
	var file = File.new()
	file.open("res://assets/dialogs/" + lang + "/strings.json", file.READ)
	var text = file.get_as_text()
	strings = parse_json(text)
	strings["item_name"] = "nothing"

# Cutscenes!

func enter_cutscene():
	Utils.enter_event()
	if in_cutscene:
		return
	in_cutscene = true
	get_node("/root/GameRoot/HUD/black_bars").play("dialog_pop_in")
	get_node("/root/GameRoot/HUD/black_bars_top").play("menu_in")

func leave_cutscene():
	Utils.leave_event()
	if not in_cutscene:
		return
	in_cutscene = false
	get_node("/root/GameRoot/HUD/black_bars").play("dialog_pop_out")
	get_node("/root/GameRoot/HUD/black_bars_top").play("menu_out")
	
func detach_camera():
	detached_camera = true

func attach_camera():
	detached_camera = false

#
# @ Choices and choice related stuff.
#

### If there is a choice going on rn
var in_choice: bool = false
### The result of the choice
var choice_result:int = 0
### If you're selecting an item with your kuro
var kuro_select:bool = false

signal choice_selected(index)
signal choice_finished(status)

### Request a choice
func choice (question:String, choices, icons, offset=0, _dialog_box=dialog_box, mode=0, text_pos=0):
	var ChoiceNode: Choice = Choice.new()
	ChoiceNode.display = mode
	ChoiceNode.dialog_box = _dialog_box
	ChoiceNode.question = question
	ChoiceNode.choices = choices
	ChoiceNode.choice_icons = icons
	ChoiceNode.text_pos = text_pos
	get_node("/root/GameRoot/WorldUI/").add_child(ChoiceNode)
	ChoiceNode.init_icons()
	match Gameplay.GAMEMODE:
		Gameplay.GM.OVERWORLD:
			ChoiceNode.position = Gameplay.playable_character_node.position + Vector2(0, offset)
		Gameplay.GM.BATTLE:
			ChoiceNode.position = BattleCore.battlers[BattleCore.battle_turn].position + Vector2(0, offset)

### Character select
func char_choice (question:String, characters, text_pos=0):
	var ChoiceNode: CharChoice = CharChoice.new()
	ChoiceNode.question = question
	ChoiceNode.choices_chars = characters
	ChoiceNode.text_pos = text_pos
	get_node("/root/GameRoot/WorldUI/").add_child(ChoiceNode)
