extends KinematicBody

onready var camera = $Cabeza/Camera
onready var rotation_helper = $Cabeza

export (PackedScene) var Bullet

var gravity = -65
var on_floor_margin = 1
var max_speed = 8
var mouse_sensitivity = 0.002  # radians/pixel
var jumps = 2
var jumpforce = 20

var velocity = Vector3()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func get_input():
	var input_dir = Vector3()
	# desired move in camera direction
	if Input.is_action_pressed("move_forward"):
		input_dir += -camera.global_transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += camera.global_transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		input_dir += -camera.global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += camera.global_transform.basis.x
	input_dir = input_dir.normalized()
	return input_dir
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(-event.relative.y * mouse_sensitivity)
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotation_helper.rotation.x = clamp(rotation_helper.rotation.x, -1.2, 1.2)
		
func _physics_process(delta):
	
	var desired_velocity = get_input() * max_speed

	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
	if Input.is_action_just_pressed("jump") and jumps > 0:
			velocity.y = jumpforce
			jumps -= 1
	
	elif is_on_floor():
		#print("floor")
		jumps = 2
		velocity.y = -on_floor_margin * delta
		
	else:
		#print("air")
		velocity.y += gravity * delta
		
	
	#disparo
	if Input.is_action_just_pressed("shoot"):
		var b = Bullet.instance()
		owner.add_child(b)
		b.transform = $Cabeza/Chutspot.global_transform
		b.velocity = -b.transform.basis.z * b.muzzle_velocity
