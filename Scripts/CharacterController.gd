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
@export var TURN_TIME = 2
@export var player_number = 0

var movement_velocity = Vector2(0, 0)
var current_aerial_jumps = 0
var is_fast_falling = false
var jump_countdown = -1
var turn_around_countdown = -1

@onready var Animation_Player = $AnimationPlayer

@onready var sprite = $Sprite2D
@onready var right_to_left = $"Front Facing Sprite"
@onready var left_to_right = $"Back Facing Sprite"

var _input_left: float
var _input_right: float
var _input_jumping: bool
var _input_crouching: bool
var _jump_just_pressed: bool

func _input(event):
	var device_id = event.device
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		device_id += 1
	if device_id != player_number:
		return
		
	if event.is_action("Move Left"):
		_input_left = event.get_action_strength("Move Left")
	if event.is_action("Move Right"):
		_input_right = event.get_action_strength("Move Right")
	
	if event.is_action("Jump"):
		_input_jumping = event.is_action_pressed("Jump")
		_jump_just_pressed = _input_jumping
	
	if event.is_action("Crouch"):
		_input_crouching = event.is_pressed()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	# Handle gravity.
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	var extra_fall_speed = FAST_FALL_SPEED if is_fast_falling else FALL_SPEED
	if not is_on_floor():
		velocity.y += (gravity + extra_fall_speed) * delta
	else:
		current_aerial_jumps = AERIAL_JUMPS
		
		
	# Handle jump.
	if _jump_just_pressed:
		if is_on_floor():
			jump_countdown = JUMP_SQUAT
		elif current_aerial_jumps > 0:
			velocity.y = AERIAL_JUMP_VELOCITY
			current_aerial_jumps -= 1
	elif jump_countdown > 0 and !_input_jumping:
		jump_countdown = -1
		velocity.y = SHORT_HOP_VELOCITY
	if jump_countdown == 0:
		jump_countdown = -1
		velocity.y = GROUNDED_JUMP_VELOCITY
	else:
		jump_countdown -= 1
		

	# Handle movement.
	var direction = _input_right - _input_left
	if direction:
		movement_velocity.x += direction * ACCELERATION
		movement_velocity.x = clampf(movement_velocity.x, -SPEED, SPEED)
	else:
		movement_velocity.x = move_toward(movement_velocity.x, 0, FRICTION if is_on_floor() else AIR_FRICTION)
	
	velocity.x = movement_velocity.x
	move_and_slide()
	
	
	# Handle turning.
	if turn_around_countdown > 0:
		turn_around_countdown -= 1
	elif turn_around_countdown == 0:
		right_to_left.visible = false
		left_to_right.visible = false
		sprite.visible = true
		turn_around_countdown = -1	
	if is_on_floor():
		if direction < 0 and not sprite.flip_h:
			right_to_left.visible = true
			sprite.visible = false
			sprite.flip_h = true
			turn_around_countdown = TURN_TIME
		elif direction > 0 and sprite.flip_h:
			left_to_right.visible = true
			sprite.visible = false
			sprite.flip_h = false
			turn_around_countdown = TURN_TIME
	
	
	# Set fast falling.
	is_fast_falling = !is_on_floor() and _input_crouching
	
	
	# Reset variables
	_jump_just_pressed = false
