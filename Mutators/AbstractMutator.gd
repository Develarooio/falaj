extends Area2D

var dormant;

func _ready():
	dormant = false
	$Sprite.set("modulate", get_color())

# Called when a player collides with the mutator
# Sets the mutators state to dormant so that other collisions will not
# retrigger consumption, starts the respawn timer and makes the
# mutator invisible
func consume():
	dormant = true
	$RespawnTimer.start()
	$Sprite.set("modulate", Color(255,255,255,0))

func reset():
	dormant = false
	$RespawnTimer.stop()
	$Sprite.set("modulate", get_color())

func _on_AbstractMutator_body_entered(body):
	if not dormant and body.is_in_group("players"):
		body.consume_mutator(get_type())
		consume()

func _on_RespawnTimer_timeout():
	reset()
