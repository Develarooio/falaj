extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var gravity = 10
var current_speed = Vector2()
var UP = Vector2(0, -1)
var bounce_coefficent = 1.0

func _ready():
	#initial velocity
	current_speed = Vector2(-50,300)
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	current_speed * bounce_coefficent
	var collision = move_and_collide(current_speed * delta)
	if collision:
		current_speed = current_speed.bounce(collision.normal)
	#write physics code oh boy
	else:
		current_speed.y += gravity