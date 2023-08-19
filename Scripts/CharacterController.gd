extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var ACCELERATION = 1
@export var FRICTION = 1
@export var AIR_FRICTION = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var movement_velocity = Vector2(0, 0)

@onready var Animation_Player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
    pass

func _physics_process(delta):
    # Add the gravity.
    if not is_on_floor():
        velocity.y += gravity * delta

    # Handle Jump.
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var direction = Input.get_axis("ui_left", "ui_right")
    if direction:
        movement_velocity.x += direction * ACCELERATION
        movement_velocity.x = clampf(movement_velocity.x, -SPEED, SPEED)
    else:
        movement_velocity.x = move_toward(movement_velocity.x, 0, FRICTION if is_on_floor() else AIR_FRICTION)
    
    velocity.x = movement_velocity.x
    move_and_slide()
