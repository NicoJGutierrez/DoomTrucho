extends Area


# Declare member variables here. Examples:
export (PackedScene) var Zombie
var timer_started: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	var z = Zombie.instance()
	owner.add_child(z)
	z.transform = $Spawnpoint.global_transform
	
#func _on_Zpawner_body_entered(body):
#	print("bum")
#	if body.is_in_group("Players") and not timer_started:
#		$Timer.start()
#	elif body.is_in_group("Players"):
#		$Timer.stop
#	pass
