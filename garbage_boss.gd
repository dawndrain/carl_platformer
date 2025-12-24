extends CharacterBody2D

@export var health: int = 20
@export var throw_interval: float = 1.5

var throw_timer = 0.0
var gravity_force = 1960.0

signal throw_garbage(pos, vel)

func _ready():
	add_to_group("enemies")
	throw_timer = 1.0

func _physics_process(delta):
	velocity.y += gravity_force * delta
	move_and_slide()

	throw_timer -= delta
	if throw_timer <= 0:
		throw_timer = throw_interval
		throw_at_player()

func throw_at_player():
	for node in get_parent().get_children():
		if node.name == "Player":
			var target_pos = node.global_position
			var dir = (target_pos - global_position).normalized()

			# Throw with arc
			var throw_vel = Vector2(dir.x * 300, -200)
			throw_garbage.emit(global_position + Vector2(0, -50), throw_vel)
			break

func take_damage(amount):
	health -= amount
	# Update health bar
	if has_node("HealthBar"):
		$HealthBar.value = health

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
			body.velocity.x = knockback_dir * 600
			body.velocity.y = -400
		else:
			body.position = Vector2(200, 1000)
