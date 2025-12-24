extends Area2D

var velocity = Vector2.ZERO
var fall_speed = 600.0

func _ready():
	collision_layer = 0
	collision_mask = 2

func _process(delta):
	velocity.y += fall_speed * delta
	position += velocity * delta
	rotation += 8.0 * delta

	if position.y > 2000:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		if not body.is_invincible():
			body.position = Vector2(200, 1000)
		queue_free()
