extends Area2D

func get_params():
	var params = {'default': true}
	return params

func _on_DefaultMutator_area_entered(area):
	if area.is_in_group('players'):
		queue_free()