extends Area2D

var life = 4.0
var speed_level = 2.0

func _process(delta):
	if get_parent().get_parent().game_running == true:
		life -= delta
		self.position -= Vector2(speed_level * 32 * delta, 0)
		if life <= 0:
			queue_free()

export var damage = {
	"amount": 1.0,
	"element": "magical",
	"type": "normal"
}

func _on_Damage_area_entered(body):
	if body.name == "Rocket":
		Utils.damage(BattleCore.battle_target, damage)
		AudioManager.play_sound("SFX_Hurt")
