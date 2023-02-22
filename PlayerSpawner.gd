extends Viewport


# Declare member variables here. Examples:
var spawnpoints = []
var player = preload("res://Player.tscn")
var player_number = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	spawnpoints = get_node('/root/Escena1/Spawnpoints').get_children()
	player_number = get_child(0).player_number
	print(player_number)
	pass # Replace with function body.


func _process(delta):
	if get_child_count() == 0:
		var p = player.instance()
		p.player_number = player_number
		var rand_spawnpoint = spawnpoints[randi() % spawnpoints.size()]
		p.transform = rand_spawnpoint.transform
		add_child(p)
	pass
