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
export var player_number = 1

var players_action_arr = [{'right' : 'p1_right','left' : 'p1_left', 'jump' : 'p1_jump', 'punch' : 'p1_punch'},
					{'right' : 'p2_right', 'left' : 'p2_left', 'jump' : 'p2_jump', 'punch' : 'p2_punch'}]
var actions = {}

func _ready():
	set_defaults()
	assign_actions()

func _physics_process(delta):
	var friction = false
	current_speed = move_and_slide(current_speed, UP)
	
	if Input.is_action_pressed(actions['right']):
		current_speed.x = min(current_speed.x + accel, max_speed)
	elif Input.is_action_pressed(actions['left']):
		current_speed.x = max(current_speed.x - accel, -max_speed)
	else:
		friction = true
	
	if is_on_floor():
		if Input.is_action_pressed(actions['jump']):
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

func set_defaults():
	max_speed = DEFAULT_MAX_SPEED
	jump_height = DEFAULT_JUMP_HEIGHT
	ball_power = DEFAULT_BALL_POWER

func get_ball_power():
	return ball_power

func assign_actions():
	if player_number == 1:
		actions = players_action_arr[0]
	else:
		actions = players_action_arr[1]

func consume_mutator(mutator_type):
	print(mutator_type)

