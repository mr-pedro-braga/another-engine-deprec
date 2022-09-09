tool
extends KinematicBody2D
class_name Kuro

enum KuroMode {
	FLOAT=0, FALL=1, DISCRETE=2, SNEK=3
}

export var character = "claire"
export(KuroMode) var mode

var input_vector
var velocity:Vector2 = Vector2.ZERO
var ACCELERATION = 1200
var FRICTION = 600
var MAX_SPEED = 64
var GRAVITY = 800

var MOVEMENT_DELAY = 0.5
var movement_timeout = 0
var snek_direction = Vector2.RIGHT

var chess_position = Vector2(1, 0)

var kuro_debug = true
var cooling_down = false

var jump_cooldown = 0.2
var jump_max_cooldown = 0.2

func _process(_delta):
	if !Engine.editor_hint:
		if character is Character:
			character = character.character_id
		#$Dust.modulate = "#" + Utils.stats[character]["attributes"]["trait"]
	if !Engine.editor_hint and (Gameplay.GAMEMODE == Gameplay.GM.BATTLE or kuro_debug) and not cooling_down:
		match character:
			"claire":
				if input_vector!=Vector2.ZERO and Input.is_action_just_pressed("ok") and input_vector != null:
					velocity = input_vector.normalized() * MAX_SPEED * 5
					cooling_down = true
					AudioManager.play("SFX_Kuro_Dash")
					var v = Utils.vfx_once.instance()
					v.animation="splash"
					v.position=position
					get_parent().add_child(v)
					yield(get_tree().create_timer(0.5), "timeout")
					cooling_down = false

func _physics_process(delta):
	if !Engine.editor_hint and (Gameplay.GAMEMODE == Gameplay.GM.BATTLE or DCCore.kuro_select or kuro_debug):
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
				if Utils.arena_status.slippery_floor:
					ACCELERATION = 200
					FRICTION = 100
				if Utils.arena_status.torus_border:
					var battle_box_real_size = Utils.battle_box_size * 5
					position = Vector2(
						fposmod(position.x + battle_box_real_size.x, battle_box_real_size.x * 2) - battle_box_real_size.x,
						fposmod(position.y + battle_box_real_size.y, battle_box_real_size.y * 2) - battle_box_real_size.y
					)
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
				velocity += Vector2(cos(Utils.arena_status.gravity), sin(Utils.arena_status.gravity)) * GRAVITY * delta
				
				### Jump!
				if Input.is_action_just_pressed("move_up"):
					$AnimPlayer.play("Jump")
				if Input.is_action_pressed("move_up") and jump_cooldown > 0.0:
					jump_cooldown -= delta
					
					var v = velocity.rotated(Utils.arena_status.gravity)
					v.x = 120
					velocity = v.rotated(-Utils.arena_status.gravity)
					
					#velocity -= Vector2(cos(Utils.arena_status.gravity), sin(Utils.arena_status.gravity)) * 180
				if Input.is_action_just_released("move_up"):
					jump_cooldown = jump_max_cooldown
				$Anim.rotation = Utils.arena_status.gravity - TAU/4
				
				ACCELERATION = 800
				FRICTION = 600
				if Utils.arena_status.slippery_floor:
					ACCELERATION = 200
					FRICTION = 100
				if Utils.arena_status.torus_border:
					var battle_box_real_size = Utils.battle_box_size * 5
					position = Vector2(
						fposmod(position.x + battle_box_real_size.x, battle_box_real_size.x * 2) - battle_box_real_size.x,
						fposmod(position.y + battle_box_real_size.y, battle_box_real_size.y * 2) - battle_box_real_size.y
					)
			KuroMode.DISCRETE:
				
				if movement_timeout > 0:
					movement_timeout -= delta * 4.0
				else:
					if Input.is_action_pressed("move_left"):
						chess_position.x -= 1
						movement_timeout = MOVEMENT_DELAY
						$AnimPlayer.play("move_discrete_horizontal")
					if Input.is_action_pressed("move_right"):
						chess_position.x += 1
						movement_timeout = MOVEMENT_DELAY
						$AnimPlayer.play("move_discrete_horizontal")
					if Input.is_action_pressed("move_up"):
						chess_position.y -= 1
						movement_timeout = MOVEMENT_DELAY
						$AnimPlayer.play("move_discrete_vertical")
					if Input.is_action_pressed("move_down"):
						chess_position.y += 1
						movement_timeout = MOVEMENT_DELAY
						$AnimPlayer.play("move_discrete_vertical")
				
				# If the piece moves to outside the board.
				if chess_position.x < 0 or chess_position.y < 0 or chess_position.x >= Utils.battle_box_size.x or chess_position.y >= Utils.battle_box_size.y:
					if Utils.arena_status.torus_border:
						chess_position = Vector2(	floor(fposmod(chess_position.x, Utils.battle_box_size.x)),
													floor(fposmod(chess_position.y, Utils.battle_box_size.y))
											)
						position = chess_position*10-Utils.battle_box_size*5 + Vector2(5, 5)
					else:
						chess_position = Vector2(	floor(clamp(chess_position.x, 0, Utils.battle_box_size.x-1)),
													floor(clamp(chess_position.y, 0, Utils.battle_box_size.y-1))
											)
				#Slide towards goal position!
				position = position.move_toward( chess_position*10-Utils.battle_box_size*5 + Vector2(5, 5) , 256 * delta)
			KuroMode.SNEK:
				
				var direction = snek_direction
				if Input.is_action_just_pressed("move_left") and direction != Vector2.RIGHT:
					snek_direction = Vector2.LEFT
					movement_timeout = 0
				if Input.is_action_just_pressed("move_right") and direction != Vector2.LEFT:
					snek_direction = Vector2.RIGHT
					movement_timeout = 0
				if Input.is_action_just_pressed("move_up") and direction != Vector2.DOWN:
					snek_direction = Vector2.UP
					movement_timeout = 0
				if Input.is_action_just_pressed("move_down") and direction != Vector2.UP:
					snek_direction = Vector2.DOWN
					movement_timeout = 0
				
				var previous_position = chess_position
				if movement_timeout <= 0:
					movement_timeout = MOVEMENT_DELAY
					if true:#not snek_body_parts.has(chess_position + snek_direction):
						chess_position += snek_direction
				else:
					movement_timeout -= delta
				
				# If the snek moves outside the board.
				if chess_position.x < 0 or chess_position.y < 0 or chess_position.x >= Utils.battle_box_size.x or chess_position.y >= Utils.battle_box_size.y:
					if Utils.arena_status.torus_border:
						chess_position = Vector2(	floor(fposmod(chess_position.x, Utils.battle_box_size.x)),
													floor(fposmod(chess_position.y, Utils.battle_box_size.y))
											)
						position = chess_position*10-Utils.battle_box_size*5 + Vector2(5, 5)
					else:
						chess_position = Vector2(	floor(clamp(chess_position.x, 0, Utils.battle_box_size.x-1)),
													floor(clamp(chess_position.y, 0, Utils.battle_box_size.y-1))
											)
				if chess_position != previous_position:
					update_body_parts()
					update()
				position = chess_position*10-Utils.battle_box_size*5 + Vector2(5, 5)
		$Dust.emitting=velocity.length()>0
		if velocity.length() > MAX_SPEED and not mode == KuroMode.FALL:
			get_node("Anim/SpriteTrail").active = true
		else:
			get_node("Anim/SpriteTrail").active = false
		velocity = move_and_slide(velocity)

export(Texture) var snek_texture

var snek_body_parts = [
	Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, 
]

func update_body_parts():
	var prev 
	var next
	for k in range(0, snek_body_parts.size()):
		next = chess_position if k == 0 else prev
		prev = snek_body_parts[k]
		snek_body_parts[k] = next

func _draw():
	if mode == KuroMode.SNEK:
		$Anim.visible = false
		
		var eating_apple = false
		var x = 0
		var y = 0
		
		# Draw body!
		for i in range(0, snek_body_parts.size()):
			var bp = snek_body_parts[i]
			# If is tail!
			if i == snek_body_parts.size() - 1:
				
				var jigsaw_map = {
					Vector2.ZERO: "r",
					Vector2.LEFT: "r",
					Vector2.UP: "d",
					Vector2.DOWN: "u",
					Vector2.RIGHT: "l"
				}
				
				var atlas_map = {
					"r": Vector2(2, 0), "l": Vector2(1, 0),
					"d": Vector2(0, 1), "u": Vector2(1, 2)
				}
				
				var atlas_position = atlas_map[ jigsaw_map[ (bp - snek_body_parts[i - 1]).normalized() ] ]
				
				x = atlas_position.x
				y = atlas_position.y
			else:
				var jigsaw_map = {
					
					Vector2.ZERO: {
						Vector2.ZERO: "dr",
						Vector2.LEFT: "dr",
						Vector2.RIGHT: "dr",
						Vector2.UP: "dr",
						Vector2.DOWN: "dr",
					},
					
					Vector2.RIGHT: {
						Vector2.DOWN: "dr",
						Vector2.LEFT: "hor",
						Vector2.UP: "ur",
						Vector2.ZERO: "dr",
						Vector2.RIGHT: "hor",
					},
					
					Vector2.UP: {
						Vector2.LEFT: "ul",
						Vector2.DOWN: "ver",
						Vector2.RIGHT: "ur",
						Vector2.ZERO: "dr",
						Vector2.UP: "ver",
					},
					
					Vector2.LEFT: {
						Vector2.DOWN: "dl",
						Vector2.RIGHT: "hor",
						Vector2.UP: "ul",
						Vector2.ZERO: "dr",
						Vector2.LEFT: "hor",
					},
					
					Vector2.DOWN: {
						Vector2.LEFT: "dl",
						Vector2.UP: "ver",
						Vector2.RIGHT: "dr",
						Vector2.ZERO: "dr",
						Vector2.DOWN: "ver",
					}
				}
				
				var atlas_map = {
					"hor": Vector2(4, 0), "ver": Vector2(6, 2),
					"dr": Vector2(2, 1), "dl": Vector2(3, 1),
					"ur": Vector2(2, 2), "ul": Vector2(3, 2)
				}
				
				if i == 0:
					continue
				
				var prev_part_position = snek_body_parts[i+1]
				var next_part_position = snek_body_parts[i-1] if i > 0 else chess_position
				
				var a = jigsaw_map[(prev_part_position - bp).normalized()]
				var b = a[(next_part_position - bp).normalized()]
				
				var atlas_position = atlas_map[b]
				
				x = atlas_position.x
				y = atlas_position.y
			draw_texture_rect_region(snek_texture,
				Rect2(-Utils.battle_box_size.x*5-position.x + bp.x*10, -Utils.battle_box_size.y*5-position.y + bp.y*10, 10, 10),
				Rect2(16*x, 16*y, 16, 16)
			)
		
		# Draw head!
		x = 0
		y = 0
		if eating_apple:
			pass
		else:
			match snek_direction:
				Vector2.RIGHT:
					x = 3
				Vector2.UP:
					x = 1
					y = 1
				Vector2.DOWN:
					y = 2
		draw_texture_rect_region(snek_texture,
			Rect2(-5, -5, 10, 10),
			Rect2(16*x, 16*y, 16, 16)
		)
	else:
		$Anim.visible = true
