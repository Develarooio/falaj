extends Area2D

func _on_DangerBox_body_entered(body):
	if body.is_in_group("players"):
		body.inflict_damage(30)
