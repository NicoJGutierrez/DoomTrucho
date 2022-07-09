extends Area

signal exploded

export var muzzle_velocity = 25
export var g = Vector3.DOWN * 20
export var laiftaim = 2

var velocity = Vector3.ZERO


func _physics_process(delta):
	laiftaim -= delta
	velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta
	if laiftaim <= 1:
		queue_free()


func _on_Shell_body_entered(body):
	emit_signal("exploded", transform.origin)
	queue_free()
