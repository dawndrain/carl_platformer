extends CharacterBody2D

var gravity = 1960.0
var follow_speed = 400.0
var shoot_cooldown = 0.0
var shoot_range = 500.0
var target_offset = Vector2(-80, 0)

@onready var player = get_parent().get_node("Player")

signal shoot_missile(pos, direction)

func _physics_process(delta):
	shoot_cooldown = max(0, shoot_cooldown - delta)

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Follow player
	if player:
		var target_pos = player.global_position + target_offset
		var distance = target_pos.x - global_position.x

		# Flip offset based on player facing
		if player.facing_direction > 0:
			target_pos = player.global_position + Vector2(-80, 0)
		else:
			target_pos = player.global_position + Vector2(80, 0)

		distance = target_pos.x - global_position.x

		if abs(distance) > 20:
			velocity.x = sign(distance) * follow_speed
			$Sprite2D.flip_h = distance < 0
		else:
			velocity.x = move_toward(velocity.x, 0, follow_speed)

		# Jump if player is above and we're on floor
		if player.global_position.y < global_position.y - 100 and is_on_floor():
			velocity.y = -700

	move_and_slide()

	# Shoot at nearby enemies
	if shoot_cooldown <= 0 and get_tree():
		var enemies = get_tree().get_nodes_in_group("enemies")
		var closest_enemy = null
		var closest_dist = shoot_range

		for enemy in enemies:
			var dist = global_position.distance_to(enemy.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_enemy = enemy

		if closest_enemy:
			var dir = sign(closest_enemy.global_position.x - global_position.x)
			$Sprite2D.flip_h = dir < 0
			shoot_missile.emit(global_position, dir)
			shoot_cooldown = 1.0
