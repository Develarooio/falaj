extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var dormant;

func _ready():
	dormant = false

# Called when a player collides with the mutator
# Sets the mutators state to dormant so that other collisions will not
# retrigger consumption, starts the respawn timer and makes the
# mutator invisible
func consume():
	dormant = true
	$RespawnTimer.start()
	$Sprite.set("modulate", Color(255,255,255,0))

func reset():
	print("resetting")
	dormant = false
	$RespawnTimer.stop()
	$Sprite.set("modulate", Color(255,255,255,255))

func _on_AbstractMutator_body_entered(body):
	if not dormant:
		body.consume_mutator(get_type())
		consume()

func _on_RespawnTimer_timeout():
	reset()
