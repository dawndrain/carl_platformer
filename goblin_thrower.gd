extends CharacterBody2D

@export var health: int = 4
@export var throw_interval: float = 2.0
@export var throw_speed: float = 400.0

var gravity = 1960.0
var throw_timer = 0.0
var rock_scene = preload("res://rock.tscn")

signal throw_rock(pos, vel)

func _ready():
	add_to_group("enemies")
	throw_timer = throw_interval * 0.5  # Start with half delay

func _physics_process(delta):
	velocity.y += gravity * delta
	move_and_slide()

	throw_timer -= delta
	if throw_timer <= 0:
		throw_timer = throw_interval
		throw_at_player()

func throw_at_player():
	var player = get_tree().get_first_node_in_group("enemies")
	# Find the player node
	var players = get_tree().get_nodes_in_group("enemies")
	for node in get_parent().get_children():
		if node.name == "Player":
			# Calculate throw direction
			var target_pos = node.global_position
			var dir = (target_pos - global_position).normalized()

			# Add arc - throw upward
			var throw_vel = Vector2(dir.x * throw_speed, -300)

			# Emit signal for level to spawn rock
			throw_rock.emit(global_position + Vector2(0, -30), throw_vel)

			# Face the player
			$Sprite2D.flip_h = dir.x < 0
			break

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
