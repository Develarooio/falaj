extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var gravity = 10
var current_speed = Vector2()
var UP = Vector2(0, -1)
var bounce_coefficent = 0.7

func _ready():
	#initial velocity
	current_speed = Vector2(-50,300)

func _physics_process(delta):
	var collision = move_and_collide(current_speed * delta)
	if collision:
		current_speed = current_speed.bounce(collision.normal)
		current_speed *= bounce_coefficent
	else:
		current_speed.y += gravity