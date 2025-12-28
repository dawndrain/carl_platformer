extends StaticBody2D

@export var health: int = 15
@export var tentacle_count: int = 4
@export var attack_interval: float = 2.0
@export var mini_spawn_interval: float = 3.0
@export var max_mini_tentacles: int = 8

var attack_timer = 0.0
var mini_spawn_timer = 0.0
var tentacles = []
var mini_tentacles = []
var player_ref = null

func _ready():
	add_to_group("enemies")
	attack_timer = 1.0

	# Find player
	player_ref = get_parent().get_node("Player")

	# Create tentacles
	for i in range(tentacle_count):
		var tentacle = create_tentacle(i)
		tentacles.append(tentacle)
		add_child(tentacle)

func create_tentacle(index):
	var tentacle = Node2D.new()
	tentacle.name = "Tentacle" + str(index)

	# Position tentacles around the body
	var angle = (index * TAU / tentacle_count) - PI/2
	tentacle.rotation = angle

	# Create segments
	var segment_count = 6
	for j in range(segment_count):
		var segment = Area2D.new()
		segment.name = "Segment" + str(j)
		segment.position = Vector2(0, 0)  # Start retracted
		segment.collision_layer = 0
		segment.collision_mask = 2
		segment.monitoring = true
		segment.monitorable = true
		segment.body_entered.connect(_on_segment_hit_player)

		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(60, 40)  # Bigger hitbox
		shape.shape = rect
		segment.add_child(shape)

		var visual = Polygon2D.new()
		# Tapered segment - bigger visuals
		var taper = 1.0 - (j * 0.1)
		var seg_width = 25 * taper
		var seg_height = 18 * taper
		visual.polygon = PackedVector2Array([
			Vector2(-seg_width, -seg_height),
			Vector2(seg_width, -seg_height),
			Vector2(seg_width, seg_height),
			Vector2(-seg_width, seg_height)
		])
		visual.color = Color(0.5, 0.3, 0.45, 1)
		segment.add_child(visual)

		tentacle.add_child(segment)

	# Store state
	tentacle.set_meta("extended", false)
	tentacle.set_meta("extend_progress", 0.0)
	tentacle.set_meta("target_angle", angle)

	return tentacle

func _process(delta):
	attack_timer -= delta
	mini_spawn_timer -= delta

	if attack_timer <= 0:
		attack_timer = attack_interval
		# Attack with a random tentacle
		var tentacle = tentacles[randi() % tentacles.size()]
		start_tentacle_attack(tentacle)

	# Spawn mini tentacles periodically
	if mini_spawn_timer <= 0:
		mini_spawn_timer = mini_spawn_interval
		spawn_mini_tentacle()

	# Update all tentacles
	for tentacle in tentacles:
		update_tentacle(tentacle, delta)

	# Update mini tentacles
	for mini in mini_tentacles.duplicate():
		if is_instance_valid(mini):
			update_mini_tentacle(mini, delta)
		else:
			mini_tentacles.erase(mini)

func start_tentacle_attack(tentacle):
	if player_ref:
		# Aim at player
		var dir = (player_ref.global_position - global_position).normalized()
		tentacle.set_meta("target_angle", dir.angle())
	tentacle.set_meta("extended", true)
	tentacle.set_meta("extend_progress", 0.0)

func update_tentacle(tentacle, delta):
	var extended = tentacle.get_meta("extended")
	var progress = tentacle.get_meta("extend_progress")
	var target_angle = tentacle.get_meta("target_angle")

	# Smoothly rotate toward target
	tentacle.rotation = lerp_angle(tentacle.rotation, target_angle, delta * 3)

	if extended:
		progress += delta * 4  # Extend speed
		if progress >= 1.0:
			progress = 1.0
			tentacle.set_meta("extended", false)
	else:
		progress -= delta * 2  # Retract speed
		if progress <= 0:
			progress = 0

	tentacle.set_meta("extend_progress", progress)

	# Update segment positions
	var segments = tentacle.get_children()
	for i in range(segments.size()):
		var segment = segments[i]
		var segment_progress = clamp(progress * segments.size() - i, 0, 1)
		var target_dist = (i + 1) * 70  # 70 pixels per segment
		segment.position = Vector2(target_dist * segment_progress, 0)

func _on_segment_hit_player(body):
	if body.name == "Player":
		if not body.is_invincible():
			# Throw player REALLY far
			var knockback_dir = sign(body.global_position.x - global_position.x)
			if knockback_dir == 0:
				knockback_dir = 1
			body.velocity.x = knockback_dir * 2500
			body.velocity.y = -1200

func _on_hitbox_body_entered(body):
	if body.name == "Player":
		if body.is_invincible():
			body.cancel_dash()
			take_damage(1)
		else:
			# Knock player back
			var knockback_dir = sign(body.global_position.x - global_position.x)
			if knockback_dir == 0:
				knockback_dir = 1
			body.velocity.x = knockback_dir * 600
			body.velocity.y = -400

func take_damage(amount):
	health -= amount

	# Update health bar
	if has_node("HealthBar"):
		$HealthBar.value = health

	# Flash red
	modulate = Color(1, 0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.15)

	if health <= 0:
		# Kill all mini tentacles when boss dies
		for mini in mini_tentacles:
			if is_instance_valid(mini):
				mini.queue_free()
		queue_free()

func spawn_mini_tentacle():
	# Clean up dead mini tentacles first
	mini_tentacles = mini_tentacles.filter(func(m): return is_instance_valid(m))

	if mini_tentacles.size() >= max_mini_tentacles:
		return

	var mini = create_mini_tentacle()
	mini_tentacles.append(mini)
	get_parent().add_child(mini)

func create_mini_tentacle():
	var mini = CharacterBody2D.new()
	mini.name = "MiniTentacle"
	mini.add_to_group("enemies")

	# Spawn near the boss
	var spawn_angle = randf() * TAU
	var spawn_dist = 100 + randf() * 100
	mini.global_position = global_position + Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_dist

	# Add collision shape
	var collision = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 15
	collision.shape = circle
	mini.add_child(collision)

	# Create visual - small tentacle blob
	var body = Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-12, -8), Vector2(0, -14), Vector2(12, -8),
		Vector2(14, 4), Vector2(8, 12), Vector2(-8, 12), Vector2(-14, 4)
	])
	body.color = Color(0.6, 0.35, 0.5, 1)
	mini.add_child(body)

	# Add small tentacle appendages
	for i in range(3):
		var tentacle_vis = Polygon2D.new()
		var angle = (i - 1) * 0.8
		var base_x = sin(angle) * 10
		tentacle_vis.polygon = PackedVector2Array([
			Vector2(base_x - 4, 10),
			Vector2(base_x + 4, 10),
			Vector2(base_x + 2, 25),
			Vector2(base_x - 2, 25)
		])
		tentacle_vis.color = Color(0.5, 0.3, 0.45, 1)
		mini.add_child(tentacle_vis)

	# Add hitbox for player collision
	var hitbox = Area2D.new()
	hitbox.collision_layer = 0
	hitbox.collision_mask = 2
	hitbox.monitoring = true
	var hitbox_shape = CollisionShape2D.new()
	var hitbox_circle = CircleShape2D.new()
	hitbox_circle.radius = 18
	hitbox_shape.shape = hitbox_circle
	hitbox.add_child(hitbox_shape)
	hitbox.body_entered.connect(_on_mini_hit_player.bind(mini))
	mini.add_child(hitbox)

	# Store movement data
	mini.set_meta("move_timer", 0.0)
	mini.set_meta("move_dir", Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized())
	mini.set_meta("health", 1)
	mini.set_meta("wiggle_offset", randf() * TAU)

	return mini

func update_mini_tentacle(mini, delta):
	if not is_instance_valid(mini):
		return

	var move_timer = mini.get_meta("move_timer")
	var move_dir = mini.get_meta("move_dir")
	var wiggle_offset = mini.get_meta("wiggle_offset")

	move_timer += delta

	# Change direction periodically
	if move_timer > 1.5:
		move_timer = 0.0
		if player_ref and is_instance_valid(player_ref):
			# Sometimes move toward player
			if randf() < 0.6:
				move_dir = (player_ref.global_position - mini.global_position).normalized()
			else:
				move_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		else:
			move_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		mini.set_meta("move_dir", move_dir)

	mini.set_meta("move_timer", move_timer)

	# Apply movement with wiggle
	var wiggle = sin(Time.get_ticks_msec() * 0.005 + wiggle_offset) * 30
	mini.velocity = move_dir * 80 + Vector2(wiggle, 0).rotated(move_dir.angle())
	mini.move_and_slide()

	# Slight rotation wiggle for visual effect
	mini.rotation = sin(Time.get_ticks_msec() * 0.008 + wiggle_offset) * 0.2

func _on_mini_hit_player(body, mini):
	if body.name == "Player":
		if body.is_invincible():
			# Player kills mini tentacle with dash
			body.cancel_dash()
			if is_instance_valid(mini):
				mini_tentacles.erase(mini)
				mini.queue_free()
		else:
			# Mini tentacle damages player with small knockback
			var knockback_dir = sign(body.global_position.x - mini.global_position.x)
			if knockback_dir == 0:
				knockback_dir = 1
			body.velocity.x = knockback_dir * 400
			body.velocity.y = -200
