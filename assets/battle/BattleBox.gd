tool
extends Node2D

export var size: Vector2 = Vector2(3, 3) setget update_size
onready var back = get_node("BattleBox/Textures/Back")
onready var border = get_node("BattleBox/Textures/Border")
onready var border_sensor = get_node("BorderSensor/Collision2")
onready var col = get_node("BattleBox/Collision")

var back_sprite = ""
func set_back(back_a):
	back.texture = load("res://assets/battle/back_"+back_a+".png")

func update_size(value):
	size = value
	if back != null:
		back.rect_position = -size/2 * 10
		back.rect_size = size * 10
		border.rect_position = -size/2 * 10 - Vector2(3, 3)
		border.rect_size = size * 10 + Vector2(6, 6)
		col.scale = size / 4
		border_sensor.scale = col.scale

func _process(_delta):
	if Engine.editor_hint:
		return
	border.modulate = Color.white
	col.disabled = false
	if Utils.arena_status.hot_border:
		border.modulate = Color(1, 0.298401, 0.054688).linear_interpolate(Color(1, 0.143311, 0.054688), sin(10*Utils.time)*0.5+0.5)
	if Utils.arena_status.torus_border:
		border.modulate = Color(0.164063, 0.275085, 1)
		col.disabled = true
		if has_node("BattleBox/Kuro"):
			var k = get_node("BattleBox/Kuro")
			if k.position.x < back.rect_position.x:
				k.position.x += back.rect_size.x+4
			if k.position.x > back.rect_position.x + back.rect_size.x+4:
				k.position.x -= back.rect_size.x+4
			if k.position.y < back.rect_position.y:
				k.position.y += back.rect_size.y+4
			if k.position.y > back.rect_position.y + back.rect_size.y+4:
				k.position.y -= back.rect_size.y+4
	if Utils.arena_status.slippery_floor and back_sprite != "blue" :
		set_back("blue")
		back_sprite = "blue"
	pass

export var damage = {
	"amount": 0.1,
	"element": "fire",
	"type": "normal"
}

func _on_Damage_area_entered(area):
	if area.name == "KuroSensor":
		if Utils.hot_border:
			Utils.damage(Gameplay.battle_target, damage)
			AudioManager.play_sound("SFX_Hurt")
