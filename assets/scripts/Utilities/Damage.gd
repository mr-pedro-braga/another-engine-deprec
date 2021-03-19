extends Area2D

export var damage = {
	"amount": 2.0,
	"element": "physical",
	"type": "normal"
}

func _on_Damage_body_entered(body):
	if body.name == "Kuro":
		Utils.damage(BattleCore.battle_target, damage)
		AudioManager.play_sound("SFX_Hurt")

func _on_Damage_body_exited(_body):
	pass # Replace with function body.
