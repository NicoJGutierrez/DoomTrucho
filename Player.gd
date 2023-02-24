extends KinematicBody

onready var camera = $Cabeza/Camera
onready var rotation_helper = $Cabeza

export (PackedScene) var Bullet

var gravity = -65
var on_floor_margin = 1
var max_speed = 8
var velocity = Vector3()
var jumps = 2
var jumpforce = 20

export var max_health = 3
var health

export var player_number = "1"

var camera_sensitivity = 2
export var VELOCITY_CAMERA_MOVEMENT_FACTOR = 2/3


func _ready():
	#hacer cuerpo invisible
	$Cuerpo.set_layer_mask_bit(int(player_number), true)
	$Cuerpo.set_layer_mask_bit(0, false)
	camera.set_cull_mask_bit(int(player_number), false)
	
	#vida inicial
	health = max_health

func get_input():
	var input_dir = Vector3()
	# desired move in camera direction
	if Input.is_action_pressed("p"+player_number+"f"):
		input_dir += -camera.global_transform.basis.z
	if Input.is_action_pressed("p"+player_number+"b"):
		input_dir += camera.global_transform.basis.z
	if Input.is_action_pressed("p"+player_number+"l"):
		input_dir += -camera.global_transform.basis.x
	if Input.is_action_pressed("p"+player_number+"r"):
		input_dir += camera.global_transform.basis.x
	input_dir -= input_dir.y * camera.global_transform.basis.y
	input_dir = input_dir.normalized()
	return input_dir
	
func get_camera_input(delta, player_speed):
	var movement = camera_sensitivity + (player_speed * VELOCITY_CAMERA_MOVEMENT_FACTOR)
	var look_up_down = Input.get_axis("p"+player_number+"lu", "p"+player_number+"ld")
	rotation_helper.rotate_x(-delta * movement * look_up_down)
	var look_left_right = Input.get_axis("p"+player_number+"lr", "p"+player_number+"ll")
	rotate_y(delta * movement * look_left_right)
	rotation_helper.rotation.x = clamp(rotation_helper.rotation.x, -1.5, 1.5)
	
	
func _physics_process(delta):
	
	var desired_velocity = get_input() * max_speed

	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	
	if Input.is_action_just_pressed("p"+player_number+"j") and jumps > 0:
			velocity.y = jumpforce
			jumps -= 1
	
	elif is_on_floor():
		#print("floor")
		jumps = 2
		velocity.y = -on_floor_margin * delta
		
	else:
		#print("air")
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("p"+player_number+"sl"):
		$AnimationPlayer.play("Slide")
	if Input.is_action_just_released("p"+player_number+"sl"):
		$AnimationPlayer.play("RESET")
	
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
	var _camera_movement = get_camera_input(delta, velocity.length())
	
	#disparo
	if Input.is_action_pressed("p"+player_number+"s"):
		if $FireRate.is_stopped():
			var b = Bullet.instance()
			get_node('/root/Escena1').add_child(b)
			b.transform = $Cabeza/Chutspot.global_transform
			b.velocity = -b.transform.basis.z * b.muzzle_velocity
			b.shooter = player_number
			$FireRate.start()
		$Cabeza/Chutspot/Particles.emitting = true
	else:
		$Cabeza/Chutspot/Particles.emitting = false
func bullet_hit():
	#print("hit")
	health -= 1
	$FloatingLifebar.update(health, max_health)
	if health == 0:
		queue_free()
		
func die():
	queue_free()

