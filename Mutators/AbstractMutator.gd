extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	print(get_type())
	


func consume(body):
	print(get_type())

func _on_AbstractMutator_body_entered(body):
	consume()
