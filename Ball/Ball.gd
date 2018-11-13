extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var gravity = 25
var current_speed = Vector2()
var UP = Vector2()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	if !is_on_floor():
		current_speed.y += gravity
	move_and_slide(current_speed, UP)
	pass
	#write physics code oh boy