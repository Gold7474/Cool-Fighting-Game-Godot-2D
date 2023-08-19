extends CharacterBody2D


@export var SPEED = 300.0
@export var GROUNDED_JUMP_VELOCITY = -400.0
@export var SHORT_HOP_VELOCITY = -200
@export var AERIAL_JUMP_VELOCITY = -1000.0
@export var ACCELERATION = 1
@export var FRICTION = 1
@export var AIR_FRICTION = 1
@export var AERIAL_JUMPS = 1
@export var FALL_SPEED = 200
@export var FAST_FALL_SPEED = 400
@export var JUMP_SQUAT = 4


var movement_velocity = Vector2(0, 0)
var current_aerial_jumps = 0
var is_fast_falling = false
var jump_countdown = -1

@onready var Animation_Player = $AnimationPlayer

@onready var sprite = $Sprite2D
@onready var right_to_left = $"Front Facing Sprite"
@onready var left_to_right = $"Back Facing Sprite"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	# Add the gravity.
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	var extra_fall_speed = FAST_FALL_SPEED if is_fast_falling else FALL_SPEED
	if not is_on_floor():
		velocity.y += (gravity + extra_fall_speed) * delta
	else:
		current_aerial_jumps = AERIAL_JUMPS
	
	# Handle Jump.
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor():
			jump_countdown = JUMP_SQUAT
		elif current_aerial_jumps > 0:
			velocity.y = AERIAL_JUMP_VELOCITY
			current_aerial_jumps -= 1
	elif jump_countdown > 0 and !Input.is_action_pressed("Jump"):
		jump_countdown = -1
		velocity.y = SHORT_HOP_VELOCITY
	if jump_countdown == 0:
		jump_countdown = -1
		velocity.y = GROUNDED_JUMP_VELOCITY
	else:
		jump_countdown -= 1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("Move Left", "Move Right")
	if direction:
		movement_velocity.x += direction * ACCELERATION
		movement_velocity.x = clampf(movement_velocity.x, -SPEED, SPEED)
	else:
		movement_velocity.x = move_toward(movement_velocity.x, 0, FRICTION if is_on_floor() else AIR_FRICTION)
	
	velocity.x = movement_velocity.x
	move_and_slide()
	
	right_to_left.visible = false
	left_to_right.visible = false
	
	if is_on_floor():
		if direction < 0:
			if sprite.flip_h == false:
				right_to_left.visible = true
			sprite.flip_h = true
		elif direction > 0:
			if sprite.flip_h:
				left_to_right.visible = true
			sprite.flip_h = false
			
	is_fast_falling = !is_on_floor() and Input.is_action_pressed("Crouch")
