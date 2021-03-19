extends Node2D

# How much time to win the battle
var battle_running = true
var start_time = 0.0
var time_elapsed = 0.0
var progress = 0.0
onready var battle_length = get_node("Theme").stream.get_length()

func _ready() -> void:
	if Engine.editor_hint:
		return
	start_time = OS.get_unix_time()
	get_node("Theme").play()
	pass

func _process(delta):
	if Engine.editor_hint:
		draw_rect(Rect2(Vector2(-16, -16), Vector2(32, 32)), Color.aqua, false, 1.0, false)
		return
	if battle_running:
		get_node("ProgressBar/ProgressHandle").position.x = -27 + 54 * progress
		time_elapsed = OS.get_unix_time() - start_time
		progress = time_elapsed/battle_length
		if progress > 1:
			battle_running = false
			progress = 1
