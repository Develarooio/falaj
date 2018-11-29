extends Area2D

export var player_number = 1

# Player textures

var player_1_texture = preload("res://Player/blue_player_box.png")
var player_2_texture = preload("res://Mutators/bird_square.png")
signal win_match

func _ready():
	if player_number == 1:
		$Sprite.texture = player_1_texture
	else:
		$Sprite.texture = player_2_texture

func _on_Goal_body_entered(body):
	if body.is_in_group("players"):
		print("player found")
		if body.is_carrying():
			print(body.player_number)
			print(player_number)
			if body.player_number == player_number:
				emit_signal("win_match", body)