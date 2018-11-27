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

# Mutatable attributes
var speed
var punch
var jump

var current_speed = Vector2()
export var player_number = 1

var players_action_arr = [{'right' : 'p1_right','left' : 'p1_left', 'jump' : 'p1_jump', 'punch' : 'p1_punch'},
					{'right' : 'p2_right', 'left' : 'p2_left', 'jump' : 'p2_jump', 'punch' : 'p2_punch'}]
var actions = {}

var entity_traits = {
		"BIRD": {
			"color": [1.0,0,0],
			"speed": 5.0,
			"jump": 10.0,
			"punch": 2.0
		},
		"SNAKE": {
			"color": [0,1.0,0],
			"speed": 10.0,
			"jump": 5.0,
			"punch": 2.0
		},
		"BEAR":  {
			"color": [0,0,1.0],
			"speed": 5.0,
			"jump": 4.0,
			"punch": 10.0
		}
	}

var mutation_state = []

func _ready():
	randomize()
	init_composition()
	set_defaults()
	assign_actions()

func init_composition():
	var rand_int = floor(rand_range(0,3))
	var comp = entity_traits.keys()[rand_int]
	consume_mutator(comp)

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

func _set_comp_color(c):
	var color = Color(c[0], c[1], c[2])

	$CompositionIndicator.modulate = color

func _current_num_mutators():
	return mutation_state.size()

func _get_mutated_attr(attr):
	var num_mutations = _current_num_mutators()
	var new_attr_val = 0
	for mut in mutation_state:
		new_attr_val += entity_traits[mut][attr]
	
	return new_attr_val / num_mutations

func _get_current_comp_color_array():
	var num_mutations = mutation_state.size()
	var next_colors = [0,0,0]
	
	for mut in mutation_state:
		var color_array = entity_traits[mut]["color"]
		for i in range(0,3):
			next_colors[i] = next_colors[i] + color_array[i]

	for i in range(0,3):
		next_colors[i] = next_colors[i] / num_mutations
	
	return next_colors

func _get_majority_comp():
	for i in entity_traits.keys():
		if mutation_state.count(i) == 2:
			return i

func adjust_composition(mutator_type):
	if mutation_state.size() == 1:
		if mutator_type == mutation_state[0]:
			return
	
	if mutation_state.size() == 2:
		if mutation_state.has(mutator_type):
			mutation_state.clear()
			mutation_state.push_back(mutator_type)
			return

	if mutation_state.size() == 4:
		var maj_comp = _get_majority_comp()
		# If we are in 50/25/25 and a mutator of the same type
		# as the 50 comes in, convert to 100% of that
		if mutator_type == maj_comp:
			mutation_state.clear()
			mutation_state.push_back(mutator_type)
		# otherwise, revert to 50/50
		else:
			mutation_state.clear()
			mutation_state.push_back(mutator_type)
			mutation_state.push_back(maj_comp)
		
		return
		
	mutation_state.push_back(mutator_type)

	
func consume_mutator(mutator_type):
	adjust_composition(mutator_type)
	var color = _get_current_comp_color_array()
	var new_jump = _get_mutated_attr("jump")
	var new_speed = _get_mutated_attr("speed")
	var new_punch = _get_mutated_attr("punch")
	jump = new_jump
	speed = new_speed
	punch = new_punch
	print(jump)
	print(speed)
	print(punch)
	_set_comp_color(color)

