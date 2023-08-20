extends Camera2D

@export var PLAYER1: Node2D
@export var PLAYER2: Node2D

@export var x_margin = 200
@export var y_margin = 200
@export var min_zoom = 1.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mid_point = (PLAYER1.global_position + PLAYER2.global_position) / 2
	position = mid_point
	
	var viewport_size = get_viewport().size
	var x_dist = abs(PLAYER1.global_position.x - PLAYER2.global_position.x)
	var y_dist = abs(PLAYER1.global_position.y - PLAYER2.global_position.y)
	var zoom_factor = min(min_zoom, viewport_size.x / (x_dist + x_margin), viewport_size.y / (y_dist + y_margin))
	set_zoom(Vector2(zoom_factor, zoom_factor))
