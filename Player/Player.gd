extends KinematicBody2D

var UP = Vector2(0, -1)

var gravity = 25
var punch_strength

# Mutatable attributes
var speed
var punch
var jump
var max_speed = 1000


# Health related state
var stunned = false
var health = 100
var can_heal = true

# utility members
var frozen = false

var current_speed = Vector2()
export var player_number = 1
var direction = 1
var releasable = true

var players_action_arr = [{'right' : 'p1_right','left' : 'p1_left', 'jump' : 'p1_jump', 'punch' : 'p1_punch'},
					{'right' : 'p2_right', 'left' : 'p2_left', 'jump' : 'p2_jump', 'punch' : 'p2_punch'}]
var actions = {}

var entity_traits = {
		"BIRD": {
			"color": [1.0,0,0],
			"speed": 700,
			"jump": 900,
			"punch": 1.0
		},
		"SNAKE": {
			"color": [0,1.0,0],
			"speed": 1000,
			"jump": 700,
			"punch": 1.0
		},
		"BEAR":  {
			"color": [0,0,1.0],
			"speed": 500,
			"jump": 800,
			"punch": 5.0
		}
	}

var mutation_state = []

var can_punch = true
var ball = null

func _ready():
	randomize()
	init_composition()
	assign_actions()
	

#######################
# HEALTH AND STUNNING #
#######################

func stun():
	stunned = true
	$Stunned.show()
	if is_carrying():
		drop_ball()
	
	$Sprite/AnimationPlayer.play("shake")
	$StunTimer.start()
	$PunchIndicator.visible = false

func _on_StunTimer_timeout():
	$Stunned.hide()
	stunned = false
	$HPRechargeIncTimer.start()

func _on_HPRechargeIncTimer_timeout():
	health += 2
	if health >= 100:
		health = 100
		$HPRechargeIncTimer.stop()

func _on_HPRechargeDebounceTimer_timeout():
	# start healing
	if not stunned:
		$HPRechargeIncTimer.start()

func _debounce_heal():
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

func get_speed():
	if is_carrying():
		return speed / 2
	else:
		return speed

func _physics_process(delta):
	check_for_quit()

	if frozen:
		play_again()
		current_speed.x = 0
		current_speed.y = 0
		return

	var friction = false
	$Health.scale.x = health/100

	current_speed = move_and_slide(current_speed, UP)
	
	if Input.is_action_pressed(actions['right']) and not stunned:
		direction = 1
		current_speed.x = min(current_speed.x + 300, get_speed())
	elif Input.is_action_pressed(actions['left']) and not stunned:
		direction = -1
		current_speed.x = max(current_speed.x - 300, -get_speed())
	else:
		friction = true
		
	if Input.is_action_just_pressed(actions['punch']) and can_punch and not is_carrying() and not stunned:
		#Charge Punch
		charge_punch()
		releasable = true
	elif Input.is_action_just_released(actions['punch']) and releasable and not stunned:
		#Release Punch
		releasable = false
		punch_strength = calc_punch_strength()
		punch()
	
	if is_on_floor():
		if Input.is_action_pressed(actions['jump']) and not stunned:
			current_speed.y -= jump
		if friction:
			current_speed.x = lerp(current_speed.x, 0, .3)
	else:
		current_speed.x = lerp(current_speed.x, 0, .6)
		current_speed.y += gravity

	if stunned:
		current_speed.x = 0
		return

	if Input.is_action_just_pressed(actions['punch']) and can_punch:
		#Charge Punch
		charge_punch()
		releasable = true
	elif Input.is_action_just_released(actions['punch']) and releasable:
		#Release Punch
		releasable = false
		punch()
	

func play_again():
	if Input.is_action_pressed('menu'):
		get_tree().change_scene('res://MainMenu.tscn')
	elif Input.is_action_pressed('quit'):
		get_tree().quit()
	elif Input.is_action_pressed('retry'):
		get_tree().change_scene(get_parent().filename)
		
func check_for_quit():
	if Input.is_action_pressed('quit'):
		get_tree().quit()

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

##################
# BALL FUN TIMES #
##################

func drop_ball():
	ball.release(current_speed)
	ball = null

func get_throw_strength():
	# REIMPLEMENT THIS WHEN PUNCH CHARGE IS A REAL NUMBER
	return punch_strength * 500

func throw_ball():
	$PunchIndicator.visible = false
	ball.release(Vector2(direction*get_throw_strength(),get_throw_strength()*-1.5))
	ball = null

func grab_ball(new_ball):
	ball = new_ball

func is_carrying():
	return ball != null

############
# PUNCHING #
############

func _on_PunchCoolDown_timeout():
	can_punch = true
	
func _on_PunchDuration_timeout():
	$Fist.visible = false
	$Fist.monitoring = false
	$PunchCoolDown.start()

func punch():
	
	if is_carrying():
		throw_ball()
		return
	
	$PunchIndicator.visible = false
	can_punch = false
	if direction == 1:
		$Fist.scale.x = 1
	else:
		$Fist.scale.x = -1
	$Fist.visible = true
	$Fist.monitoring = true
	$PunchDuration.start()

func charge_punch():
	$PunchIndicator.visible = true
	$AnimationPlayer.play('punch_charge_bar', -1, punch)

func calc_punch_strength():
	return $AnimationPlayer.current_animation_position/$AnimationPlayer.current_animation_length

	
func inflict_knock_back(dir):
	current_speed += Vector2(dir.x*.50, dir.y-250)

func _on_Fist_body_entered(body):
	if body.is_in_group('players') and self != body:
		var damage = round(punch_strength*100)
		body.inflict_damage(damage)
		var direction = body.position - position
		body.inflict_knock_back(direction*damage)