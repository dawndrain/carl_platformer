extends CharacterBody2D

var health = 3
var speed = 160.0
var direction = 1
var gravity = 1960.0

func _ready():
	add_to_group("enemies")

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity.x = direction * speed
	
	move_and_slide()
	
	if is_on_wall():
		direction *= -1

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
	else:
		modulate = Color(1, 0.5, 0.5)
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 0.3, 0.3), 0.1)

func _on_hitbox_body_entered(body):
	if body.name == "Player":
		if body.is_invincible():
			body.cancel_dash()
			var knockback_dir = sign(body.global_position.x - global_position.x)
			if knockback_dir == 0:
				knockback_dir = 1
			body.velocity.x = knockback_dir * 400
			body.velocity.y = -300
		else:
			body.position = Vector2(800, 400)
