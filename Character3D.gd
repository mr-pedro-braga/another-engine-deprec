tool
extends KinematicBody

# Character ID for movements and such. #
export var character_id = "claire"
export var local_instance_id = 0
export var update_actions = true

export var action = "idle"

# Movement Variables #
var ignoring_inputs = true
var velocity:Vector3 = Vector3.ZERO
var ACCELERATION = 200
var FRICTION = 200
var MAX_SPEED = 0

export var angle = 2

func _ready():
	ignoring_inputs = false

# Physics #
func _physics_process(delta):
	var input_vector
	if not Engine.editor_hint:
		# Movement
		if (not ignoring_inputs) and character_id == Gameplay.playable_character:		
			input_vector = Vector3(
				Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
				Input.get_action_strength("move_down") - Input.get_action_strength("move_up"),
				0.0
			)
			input_vector = input_vector.normalized()
			if input_vector != Vector3.ZERO:
				velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
			else:
				velocity = velocity.move_toward(Vector3.ZERO, min(FRICTION * delta, velocity.length()))
	
		
		var a = Vector2(round(velocity.x*8)/8, round(velocity.y*8)/8)
		move_and_collide(Vector3(a.x, 0.0, a.y) * delta)
		
		# Actions
		if Input.is_action_pressed("run"):
			MAX_SPEED = 0.1
		elif Input.is_action_pressed("sneak"):
			MAX_SPEED = 0.1
		else:
			MAX_SPEED = 5.8
		
		# Animation
		if update_actions:
			if velocity.length() > 1.0:
				action = "walk"
			else:
				action = "idle"
		# Camera
		if velocity != Vector3.ZERO:
			angle = (fposmod(round((Vector2.RIGHT.angle_to(Vector2(velocity.x, velocity.y)) / (2*PI)) * 8), 8))
	$AnimatedSprite3D.play(action + "_" + str(angle))
