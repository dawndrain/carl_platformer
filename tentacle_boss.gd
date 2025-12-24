extends StaticBody2D

@export var health: int = 15
@export var tentacle_count: int = 4
@export var attack_interval: float = 2.0

var attack_timer = 0.0
var tentacles = []
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

	if attack_timer <= 0:
		attack_timer = attack_interval
		# Attack with a random tentacle
		var tentacle = tentacles[randi() % tentacles.size()]
		start_tentacle_attack(tentacle)

	# Update all tentacles
	for tentacle in tentacles:
		update_tentacle(tentacle, delta)

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
			# Knock player back
			var knockback_dir = sign(body.global_position.x - global_position.x)
			if knockback_dir == 0:
				knockback_dir = 1
			body.velocity.x = knockback_dir * 800
			body.velocity.y = -400

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
		queue_free()
