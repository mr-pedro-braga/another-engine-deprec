tool
extends KinematicBody2D
class_name Kuro

enum KuroMode {
	FLOAT=0, FALL=1, WEBS=2
}

export var character = "claire"
export var mode: int = 1

var input_vector
var velocity:Vector2 = Vector2.ZERO
var ACCELERATION = 700
var FRICTION = 600
var MAX_SPEED = 64
var GRAVITY = 800
var GRAVITY_ANGLE = PI/2

var cooling_down = false

func _process(_delta):
	if !Engine.editor_hint:
		if character is Character:
			character = character.character_id
		#$Dust.modulate = "#" + Utils.stats[character]["attributes"]["trait"]
	if !Engine.editor_hint and (Gameplay.GAMEMODE == Gameplay.GM.BATTLE) and not cooling_down:
		match character:
			"claire":
				if input_vector!=Vector2.ZERO and Input.is_action_just_pressed("ok") and input_vector != null:
					velocity = input_vector.normalized() * MAX_SPEED * 5
					cooling_down = true
					AudioManager.play("SFX_Kuro_Dash.wav")
					var v = Utils.vfx_once.instance()
					v.animation="splash"
					v.position=position
					get_parent().add_child(v)
					yield(get_tree().create_timer(0.5), "timeout")
					cooling_down = false

func _physics_process(delta):
	if !Engine.editor_hint and (Gameplay.GAMEMODE == Gameplay.GM.BATTLE or DCCore.kuro_select):
		match mode:
			KuroMode.FLOAT:
				input_vector = Vector2(
					Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
					Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
				)
				input_vector = input_vector.normalized()
				if input_vector != Vector2.ZERO:
					velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
				else:
					velocity = velocity.move_toward(Vector2.ZERO, min(FRICTION * delta, velocity.length()))
				ACCELERATION = 700
				FRICTION = 600
				if Utils.slipery_floor:
					ACCELERATION = 200
					FRICTION = 100
			KuroMode.FALL:
				input_vector = Vector2(
					Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
					0.0
				)
				
				if input_vector != Vector2.ZERO:
					var cx = input_vector * MAX_SPEED
					velocity = Vector2(Vector2(velocity.x, 0.0).move_toward(cx, ACCELERATION * delta).x, velocity.y)
				else:
					var cx = Vector2.ZERO
					var f = min(FRICTION * delta, velocity.length())
					velocity = Vector2(Vector2(velocity.x, 0.0).move_toward(cx, f).x, velocity.y)
				velocity += Vector2(cos(GRAVITY_ANGLE), sin(GRAVITY_ANGLE)) * GRAVITY * delta
				
				### Jump!
				if Input.is_action_just_pressed("move_up"):
					velocity -= Vector2(cos(GRAVITY_ANGLE), sin(GRAVITY_ANGLE)) * 180
				
				ACCELERATION = 800
				FRICTION = 600
				if Utils.slipery_floor:
					ACCELERATION = 200
					FRICTION = 100
		$Dust.emitting=velocity.length()>0
		if velocity.length() > MAX_SPEED:
			get_node("Anim/SpriteTrail").active = true
		else:
			get_node("Anim/SpriteTrail").active = false
		velocity = move_and_slide(velocity)
