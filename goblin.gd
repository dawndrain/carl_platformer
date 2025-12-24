extends CharacterBody2D

@export var health: int = 3
@export var speed: float = 160.0
@export var sprite_scale: float = 1.0

var direction = 1
var gravity = 1960.0

func _ready():
	add_to_group("enemies")
	$Sprite2D.scale = Vector2(sprite_scale, sprite_scale)

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity.x = direction * speed

	move_and_slide()

	if is_on_wall():
		direction *= -1
		$Sprite2D.flip_h = direction < 0

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
	else:
		modulate = Color(1, 0.5, 0.5)
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)

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
			body.position = Vector2(200, 400)
