extends KinematicBody2D

var max_speed = 600
var accel = 200
var gravity = 25
var jump_height = 700
var current_speed = Vector2()
var UP = Vector2(0, -1)

func _ready():
	pass

func _physics_process(delta):
	var friction = false
	
	if Input.is_action_pressed('right'):
		current_speed.x = min(current_speed.x + accel, max_speed)
	elif Input.is_action_pressed('left'):
		current_speed.x = max(current_speed.x - accel, -max_speed)
	else:
		friction = true
	
	if is_on_floor():
		if Input.is_action_pressed('jump'):
			current_speed.y -= jump_height
	else:
		current_speed += gravity