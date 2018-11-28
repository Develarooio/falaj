extends Node2D

func _on_Goal_win_match(player):
	win_match(player)

func _on_Goal2_win_match(player):
	win_match(player)

func win_match(player):
	$WINTEXT.text = "Player " + str(player.player_number) + " WON"
	$WINTEXT.show()
	player.frozen = true

