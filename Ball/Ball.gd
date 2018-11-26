extends KinematicBody2D

var gravity = 10
var current_speed = Vector2()
var UP = Vector2(0, -1)
var bounce_coefficent = 0.7
var held = false
var player = null

func _physics_process(delta):
	if !held:
		var collision = move_and_collide(current_speed * delta)
		if collision:
			var body = collision.collider
			if !body.is_in_group('players'):
				current_speed = current_speed.bounce(collision.normal)
				current_speed *= bounce_coefficent
		else:
			current_speed.y += gravity
	else:
		position = player.global_position

func _on_PlayerImpactDetector_area_entered(area):
	if area.is_in_group('players'):
		player = area
		held = true

func release(direction):
	current_speed = direction
	held = false