tool
extends EditorPlugin

#@ Monitores script changes and enables SSON text highlighting!

var tabs: TabContainer

func _enter_tree() -> void:
	var e
	e = get_editor_interface().get_base_control().get_child(1).get_child(1).get_child(1).get_child(1).get_child(0).get_child(0).get_child(0).get_child(0).get_child(1).get_child(0)
	tabs = e.get_child(2).get_child(0).get_child(1).get_child(1)
	tabs.connect("tab_changed", self, "script_changed")

func _exit_tree() -> void:
	for editor in tabs.get_children():
		var text_edit = editor.get_child(0).get_child(0)
		if text_edit is TextEdit:
			text_edit.clear_colors()

func script_changed(script_index):
	var text_edit = tabs.get_child(script_index).get_child(0).get_child(0)
	if text_edit is TextEdit:
		setup_colors(text_edit)

var keywords = [
	"move", "choice", "mvto", "mvadd", "wait", "turn", "pose",
	"anim", "action", "face", "call", "switch", "var", "important",
	"continue", "back", "goto", "await",
	"and", "or", "xor", "not", "if", "unless", "elif", "else",
	"compare", "case", "menu", "default",
	"item", "give", "take", "doctype", "bgm", "pause", "resume", "restart",
	"path", "append", "lock", "unlock",
	"text_mode", "speech_delay", "sfx", "camera", "shake",
	
	"base_damage", "source",
	"beatcode_tempo", "beatcode_script",
	
	"process", "damage_mode", "damage_scale", "type",
	"script", "minigame",
	"clock_interval", "sprite",
	"battle_box",
	"position", "angle", "sprite_angle", "accel_angle", "moving_angle",
	"speed", "accel",
]

var keywords2 = [
	"static", "projectile", "minigame", "bullets", "animation",
	"physical", "spirit", "magic", "light", "darkness", "pure",
	"normal", "when_moving", "when_idle",
	"randf", "randi", "rand_range", "min", "max", "clamp",
	"floor", "ceil", "round", "vector2", "sin", "cos", "tan", "atan", "asin", "acos", 
	"Vector2",
	
	"once", "true", "false", "yes", "no", "on", "off",
	"PLAYER_POS", "TAU", "PI", "e",
]

func setup_colors(text_edit:TextEdit):
	var keyword_color: Color = get_editor_interface().get_editor_settings().get_setting("text_editor/highlighting/keyword_color")
	var text_color: Color = get_editor_interface().get_editor_settings().get_setting("text_editor/highlighting/text_color")
	var string_color: Color = get_editor_interface().get_editor_settings().get_setting("text_editor/highlighting/string_color")
	var secondary_color: Color = get_editor_interface().get_editor_settings().get_setting("text_editor/highlighting/engine_type_color")
	var comment_color: Color = get_editor_interface().get_editor_settings().get_setting("text_editor/highlighting/comment_color")
	
	# Tags
	text_edit.add_color_region("--", "", keyword_color)
	# Text
	text_edit.add_color_region("#", "", comment_color)
	text_edit.add_color_region(": ", "", text_color)
	text_edit.add_color_region("* ", "", text_color)
	text_edit.add_color_region('"', '"', string_color)
	
	# Simple Keywords
	for key in keywords:
		text_edit.add_keyword_color(key, keyword_color)
	for key in keywords2:
		text_edit.add_keyword_color(key, secondary_color)

