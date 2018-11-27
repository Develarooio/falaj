extends KinematicBody2D

var UP = Vector2(0, -1)
var DEFAULT_BALL_POWER = 300

var ball_power
var gravity = 25


# Mutatable attributes
var speed
var punch
var jump
var max_speed = 1000


# Health related state
var stunned = false
var health = 100
var can_heal = true

var current_speed = Vector2()
export var player_number = 1
var direction = 1

var players_action_arr = [{'right' : 'p1_right','left' : 'p1_left', 'jump' : 'p1_jump', 'punch' : 'p1_punch'},
					{'right' : 'p2_right', 'left' : 'p2_left', 'jump' : 'p2_jump', 'punch' : 'p2_punch'}]
var actions = {}

var entity_traits = {
		"BIRD": {
			"color": [1.0,0,0],
			"speed": 200,
			"jump": 1200,
			"punch": 2.0
		},
		"SNAKE": {
			"color": [0,1.0,0],
			"speed": 600,
			"jump": 700,
			"punch": 2.0
		},
		"BEAR":  {
			"color": [0,0,1.0],
			"speed": 100,
			"jump": 800,
			"punch": 10.0
		}
	}

var mutation_state = []

var can_punch = true
var holding = false

func _ready():
	randomize()
	init_composition()
	assign_actions()

#######################
# HEALTH AND STUNNING #
#######################

func stun():
	stunned = true
	$Sprite/AnimationPlayer.play("shake")
	$StunTimer.start()

func _on_StunTimer_timeout():
	stunned = false
	$HPRechargeIncTimer.start()

func _on_HPRechargeIncTimer_timeout():
	health += 2
	if health >= 100:
		health = 100
		$HPRechargeIncTimer.stop()

func _on_HPRechargeDebounceTimer_timeout():
	# start healing
	$Debouncing.hide()
	if not stunned:
		$HPRechargeIncTimer.start()

func _debounce_heal():
	$Debouncing.show()
	$HPRechargeDebounceTimer.start()

func inflict_damage(dmg):
	health -= dmg
	$HPRechargeIncTimer.stop()
	if health < 0:
		health = 0
	
	if health == 0:
		stun()
	else:
		_debounce_heal()

##################
# INITIALIZATION #
##################

func init_composition():
	var rand_int = floor(rand_range(0,3))
	var comp = entity_traits.keys()[rand_int]
	consume_mutator(comp)

func assign_actions():
	if player_number == 1:
		actions = players_action_arr[0]
	else:
		actions = players_action_arr[1]

############
# MOVEMENT #
############

func _physics_process(delta):
	#if $PunchCoolDown.paused() == false:
	#	print('punch is cooling down')
		
	var friction = false
	$TmpHealthLabel.set("text", str(health))
	# early return and do no physics processing if currently stunned
	if stunned:
		current_speed.x = 0
		return
	
	current_speed = move_and_slide(current_speed, UP)
	
	if Input.is_action_pressed(actions['right']):
		direction = 1
		current_speed.x = min(current_speed.x + speed, max_speed)
	elif Input.is_action_pressed(actions['left']):
		direction = -1
		current_speed.x = max(current_speed.x - speed, -max_speed)
	else:
		friction = true
	
	if Input.is_action_just_pressed(actions['punch']) and can_punch and not holding:
		punch()
	
	if is_on_floor():
		if Input.is_action_pressed(actions['jump']):
			current_speed.y -= jump
		if friction:
			current_speed.x = lerp(current_speed.x, 0, .3)
	else:
		current_speed.x = lerp(current_speed.x, 0, .2)
		current_speed.y += gravity

############
# MUTATION #
############

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
	_set_comp_color(color)

func _on_PunchCoolDown_timeout():
	can_punch = true
	
func _on_PunchDuration_timeout():
	$Fist.visible = false
	$PunchCoolDown.start()

func punch():
	can_punch = false
	if direction == 1:
		$Fist.scale.x = 1
	else:
		$Fist.scale.x = -1
	$Fist.visible = true
	$PunchDuration.start()

func set_holding(val):
	holding = val