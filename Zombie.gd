extends KinematicBody


# Declare member variables here. Examp
export var max_health = 3
var health

onready var nav: Navigation = $"../Navigation"
#onready var player: KinematicBody = $"../Player"
var target: KinematicBody = null
var path: Array = []
export var speed: int = 4
var current_node = 0
var margin = .1

var velocity = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
#	update_path(player.global_transform.origin)
	health = max_health
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if path.size() > 0:
		move_to_target(target)


func bullet_hit():
	#print("hit")
	health -= 1
	$VidaDeZombie.update(health, max_health)
	if health == 0:
		queue_free()

func move_to_target(target):
	if current_node >= path.size():
		return
	elif global_transform.origin.distance_to(path[current_node]) < margin:
		current_node += 1
	else:
		var direction: Vector3 = path[current_node] - global_transform.origin
		velocity = direction.normalized() * speed
		move_and_slide(velocity, Vector3.UP)
		pass
		
	#path = nav.get_simple_path(global_transform.origin, target)
#	#print(path)


#func _on_Timer_timeout():
#	update_path(player.global_transform.origin)
#	current_node = 0
