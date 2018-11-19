extends KinematicBody2D

var DEFAULT_MAX_SPEED = 600
var DEFAULT_JUMP_HEIGHT = 700
var UP = Vector2(0, -1)
var DEFAULT_BALL_POWER = 300

var ball_power
var max_speed
var accel = 200
var gravity = 25
var jump_height
var current_speed = Vector2()

func _ready():
	set_defaults()

func _physics_process(delta):
	var friction = false
	current_speed = move_and_slide(current_speed, UP)
	
	if Input.is_action_pressed('right'):
		current_speed.x = min(current_speed.x + accel, max_speed)
	elif Input.is_action_pressed('left'):
		current_speed.x = max(current_speed.x - accel, -max_speed)
	else:
		friction = true
	
	if is_on_floor():
		if Input.is_action_pressed('jump'):
			current_speed.y -= jump_height
		if friction:
			current_speed.x = lerp(current_speed.x, 0, .3)
	else:
		current_speed.x = lerp(current_speed.x, 0, .2)
		current_speed.y += gravity

func velocity():
	return current_speed

func _on_Detector_area_entered(area):
	#Check if its a mutator
	if area.is_in_group('mutators'):
		var new_params = area.get_params()
		assign_params(new_params)

func assign_params(params):
	#Hmmmmm on second thought this is stupid.  Maybe the player should just have all of this info
	#and the mutators are just a flag to switch?  HMMMM HMMMM I DUNNO
	if params.has('default'):
		set_defaults()
	if params.has('jump_height'):
		jump_height = params['jump_height']
	if params.has('max_speed'):
		max_speed = params['max_speed']

func set_defaults():
	max_speed = DEFAULT_MAX_SPEED
	jump_height = DEFAULT_JUMP_HEIGHT
	ball_power = DEFAULT_BALL_POWER

func get_ball_power():
	return ball_power
