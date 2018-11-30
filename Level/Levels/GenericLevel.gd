extends Node


func _ready():
	$Goal1.connect('win_match', self, 'win_match')
	$Goal2.connect('win_match', self, 'win_match')

func win_match(player):
	$WINTEXT.text = "PLAYER " + str(player.player_number) + " WON, Esc to Quit, R to Retry, M to Menu"
	$WINTEXT.show()
	$Player1.frozen = true
	$Player2.frozen = true
	