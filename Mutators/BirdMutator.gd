extends Area2D

export var jump_height = 1000

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func get_params():
	var params = {'jump_height': jump_height}

	return params

func _on_BirdMutator_area_entered(area):
	if area.is_in_group('players'):
		queue_free()
