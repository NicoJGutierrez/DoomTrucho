extends Sprite3D

onready var barra = $Viewport/Lifebar

export var green = preload("res://lifebar_textures/barHorizontal_green.png")
export var yellow = preload("res://lifebar_textures/barHorizontal_yellow.png")
export var red = preload("res://lifebar_textures/barHorizontal_red.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = $Viewport.get_texture()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(health, max_health):
	barra.max_value = max_health
	barra.value = health
	if health <= max_health/2:
		barra.texture_progress = red
	else:
		barra.texture_progress = yellow
