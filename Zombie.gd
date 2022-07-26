extends KinematicBody


# Declare member variables here. Examp
export var health = 2


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func bullet_hit():
	#print("hit")
	health -= 1
	if health == 0:
		queue_free()
