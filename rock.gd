extends Area2D

var velocity = Vector2.ZERO
var fall_speed = 800.0

func _ready():
	# Set collision to detect player
	collision_layer = 0
	collision_mask = 2

func _process(delta):
	velocity.y += fall_speed * delta
	position += velocity * delta
	rotation += 5.0 * delta

	# Remove if off screen
	if position.y > 2000:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		if not body.is_invincible():
			# Respawn player
			body.position = Vector2(200, 400)
		queue_free()
