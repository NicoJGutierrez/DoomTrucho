extends KinematicBody


# Declare member variables here. Examp
export var max_health = 2
var health

# Called when the node enters the scene tree for the first time.
func _ready():
	health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func bullet_hit():
	#print("hit")
	health -= 1
	$VidaDeZombie.update(health, max_health)
	if health == 0:
		queue_free()
