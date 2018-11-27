extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func velocity():
	return get_parent().velocity()

func get_ball_power():
	return get_parent().get_ball_power()

func set_holding(val):
	get_parent().set_holding(val)