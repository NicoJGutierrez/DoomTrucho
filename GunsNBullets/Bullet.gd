extends Area

signal exploded

export var muzzle_velocity = 40
export var g = Vector3.DOWN * 20
export var laiftaim = 3
export var shooter = ""

var velocity = Vector3.ZERO

func _physics_process(delta):
	laiftaim -= delta
	#velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta
	if laiftaim <= 1:
		#print("bam")
		queue_free()


func _on_Bullet_body_entered(body):
	#print(body.name)
	if body.name != shooter:
		if body.is_in_group("Players"):
			body.bullet_hit() 
		emit_signal("exploded", transform.origin)
		queue_free()
