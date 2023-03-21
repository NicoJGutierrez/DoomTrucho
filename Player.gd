extends KinematicBody

onready var camera = $Cabeza/Camera
onready var rotation_helper = $Cabeza
onready var raycast = $Cabeza/Camera/RayCast

export (PackedScene) var Bullet
export (PackedScene) var BulletSticker

export var gravity = -50
var applied_gravity = gravity
var on_floor_margin = 1
var max_speed = 8
var slide_speed = 10
var velocity = Vector3()
var stored_velocity = Vector3()
export var max_jumps = 1
var jumps = max_jumps
var jumpforce = 35
var in_air = false

export var max_health = 3
var health

export var player_number = "1"

var camera_sensitivity = 3
export var VELOCITY_CAMERA_MOVEMENT_FACTOR = 2/3
export var CROUCH_FACTOR = 0.7


func _ready():
	#hacer cuerpo invisible
	$Cuerpo.set_layer_mask_bit(int(player_number), true)
	$Cuerpo.set_layer_mask_bit(0, false)
	camera.set_cull_mask_bit(int(player_number), false)
	
	#vida inicial
	health = max_health
	
	#raycast ignores self
	raycast.add_exception($".")

func _physics_process(delta):
	
	
	
	var desired_velocity = get_input() * max_speed
	if not Input.is_action_pressed("p"+player_number+"sl"):
		if is_on_floor():
			if in_air == true:
				$Bhop.start()
				in_air = false
			applied_gravity = gravity
			if $Bhop.is_stopped():
				stored_velocity = Vector3(0,0,0)
		velocity.x = desired_velocity.x
		velocity.z = desired_velocity.z
		stored_velocity = stored_velocity.length() * direction_forward()
	elif stored_velocity == Vector3.ZERO:
		velocity.x = desired_velocity.x * CROUCH_FACTOR
		velocity.z = desired_velocity.z * CROUCH_FACTOR
		
	
	#jump + doublejump
	if Input.is_action_just_pressed("p"+player_number+"j") and jumps > 0:
			in_air = true
			velocity.y = jumpforce * 0.75
			jumps -= 1
			velocity.x = desired_velocity.x
			velocity.z = desired_velocity.z
	elif is_on_floor():
		jumps = max_jumps
		velocity.y = -on_floor_margin * delta
	else:
		velocity.y += applied_gravity * delta
	
	#   ===================
	#	==== S L I D E ====
	#   ===================
	
	if Input.is_action_just_pressed("p"+player_number+"sl"):
		$AnimationPlayer.play("Slide")
		if is_on_floor():
			var direction = get_input()
			var slide = slide_speed * direction
			stored_velocity += Vector3(slide.x, 0, slide.z)
		else:
			velocity += Vector3(0, gravity, 0)
	if Input.is_action_just_released("p"+player_number+"sl"):
		$AnimationPlayer.play("RESET")
	
	var _movement = move_and_slide(velocity + stored_velocity, Vector3.UP, true)
	
	var _camera_movement = get_camera_input(delta, velocity.length())
	
	#disparo
	if Input.is_action_pressed("p"+player_number+"s"):
		shoot_raycast() #shoot(Bullet)
		$Cabeza/Gun2/AnimationPlayer.play("Shoot")

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
	rotation_helper.rotate_x(-delta * movement * look_up_down * abs(look_up_down))
	var look_left_right = Input.get_axis("p"+player_number+"lr", "p"+player_number+"ll")
	rotate_y(delta * movement * look_left_right * abs(look_left_right))
	rotation_helper.rotation.x = clamp(rotation_helper.rotation.x, -1.5, 1.5)

func shoot(projectile):
	if $FireRate.is_stopped():
			var b = projectile.instance()
			get_node('/root/Escena1').add_child(b)
			b.transform = $Cabeza/Chutspot.global_transform
			b.velocity = -b.transform.basis.z * b.muzzle_velocity
			b.shooter = player_number
			$FireRate.start()

func shoot_raycast():
	if $FireRate.is_stopped():
		shoot_particles()
		if raycast.is_colliding():
			var target = raycast.get_collider()
			#hit
			if target.is_in_group("Players"):
				if target.player_number != player_number:
					target.bullet_hit()
			else:
				add_sticker()
		$FireRate.start()

func bullet_hit():
	health -= 1
	$FloatingLifebar.update(health, max_health)
	if health == 0:
		queue_free()
		
func die():
	queue_free()
	
func direction_forward():
	var input_dir = -camera.global_transform.basis.z
	input_dir -= input_dir.y * camera.global_transform.basis.y
	return input_dir.normalized()
	
func shoot_particles():
		$Cabeza/Gun2/Cube_007/MuzzleFlash.restart()
		$Cabeza/Gun2/Cube_007/MuzzleFlash.emitting = true
		$Cabeza/Gun2/Cube_007/ShootParticle.restart()
		$Cabeza/Gun2/Cube_007/ShootParticle.emitting = true

func add_sticker():
	var sticker = BulletSticker.instance()
	get_tree().get_root().add_child(sticker)
	sticker.global_transform.origin = raycast.get_collision_point()
	var surface_dir_up = Vector3(0,1,0)
	var surface_dir_down = Vector3(0,-1,0)
	
	if raycast.get_collision_normal() == surface_dir_up:
		sticker.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)
	elif raycast.get_collision_normal() == surface_dir_down:
		sticker.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)
	else:
		sticker.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.DOWN)
