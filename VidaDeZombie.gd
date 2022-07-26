extends Sprite3D

onready var barra = $Viewport/Lifebar

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = $Viewport.get_texture()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(health, max_health):
	barra.max_value = max_health
	barra.value = health
