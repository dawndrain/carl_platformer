extends CharacterBody2D

const SPEED = 600.0
const JUMP_VELOCITY = -800.0
const DASH_SPEED = 1600.0
const DASH_DURATION = 0.15
const TELEPORT_DISTANCE = 300.0
const STOMP_VELOCITY = 1600.0

var gravity = 1960.0
var jump_count = 0
var max_jumps = 2
var facing_direction = 1

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown = 0.0
var teleport_cooldown = 0.0
var missile_cooldown = 0.0
var bomb_cooldown = 0.0
var is_stomping = false
var invincible_timer = 0.0
var _h_pressed = false

signal spawn_missile(pos, direction)
signal spawn_bomb(pos, direction)

func _process(_delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

	# Reset if fallen off screen
	if global_position.y > 2000:
		get_tree().reload_current_scene()

	# Toggle controls display
	if Input.is_physical_key_pressed(KEY_H) and not _h_pressed:
		$UI/ControlsPanel.visible = not $UI/ControlsPanel.visible
	_h_pressed = Input.is_physical_key_pressed(KEY_H)

	# Level skip keys for playtesting
	if Input.is_key_pressed(KEY_0):
		get_tree().change_scene_to_file("res://intro.tscn")
	if Input.is_key_pressed(KEY_1):
		get_tree().change_scene_to_file("res://main.tscn")
	if Input.is_key_pressed(KEY_2):
		get_tree().change_scene_to_file("res://level2.tscn")
	if Input.is_key_pressed(KEY_3):
		get_tree().change_scene_to_file("res://cutscene1.tscn")
	if Input.is_key_pressed(KEY_4):
		get_tree().change_scene_to_file("res://platform0.tscn")
	if Input.is_key_pressed(KEY_5):
		get_tree().change_scene_to_file("res://platform1.tscn")
	if Input.is_key_pressed(KEY_6):
		get_tree().change_scene_to_file("res://platform2.tscn")
	if Input.is_key_pressed(KEY_7):
		get_tree().change_scene_to_file("res://garbage_pile.tscn")
	if Input.is_key_pressed(KEY_8):
		get_tree().change_scene_to_file("res://thrower_arena.tscn")
	if Input.is_key_pressed(KEY_9):
		get_tree().change_scene_to_file("res://tentacle_arena.tscn")

func _physics_process(delta):
	dash_cooldown = max(0, dash_cooldown - delta)
	teleport_cooldown = max(0, teleport_cooldown - delta)
	missile_cooldown = max(0, missile_cooldown - delta)
	bomb_cooldown = max(0, bomb_cooldown - delta)
	invincible_timer = max(0, invincible_timer - delta)
	
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		velocity.x = facing_direction * DASH_SPEED
		velocity.y = 0
		move_and_slide()
		return
	
	if is_stomping:
		velocity.x = 0
		velocity.y = STOMP_VELOCITY
		# Spin while stomping
		$Sprite2D.rotation += 25.0 * delta
		move_and_slide()
		if is_on_floor():
			is_stomping = false
			$Sprite2D.rotation = 0
			stomp_land()
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jump_count = 0
		is_stomping = false

	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		facing_direction = sign(direction)
		$Sprite2D.flip_h = facing_direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0:
		start_dash()
	
	if Input.is_action_just_pressed("teleport") and teleport_cooldown <= 0:
		do_teleport()
	
	if Input.is_action_just_pressed("missile") and missile_cooldown <= 0:
		fire_missile()
	
	if Input.is_action_just_pressed("stomp") and not is_on_floor():
		start_stomp()

	if Input.is_key_pressed(KEY_B) and bomb_cooldown <= 0:
		throw_bomb()

	move_and_slide()

func start_dash():
	is_dashing = true
	dash_timer = DASH_DURATION
	dash_cooldown = 0.5

func do_teleport():
	position.x += facing_direction * TELEPORT_DISTANCE
	teleport_cooldown = 0.8

func fire_missile():
	missile_cooldown = 0.3
	spawn_missile.emit(global_position, facing_direction)

func throw_bomb():
	bomb_cooldown = 0.8
	spawn_bomb.emit(global_position, facing_direction)

func start_stomp():
	is_stomping = true
	velocity = Vector2.ZERO

func stomp_land():
	invincible_timer = 0.5
	# Create shockwave effect
	create_shockwave()
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(global_position) < 200:
			enemy.take_damage(2)

func create_shockwave():
	# Create expanding ring effect
	var shockwave = Node2D.new()
	shockwave.position = Vector2.ZERO
	add_child(shockwave)

	# Draw circle using a polygon
	var ring = Polygon2D.new()
	var points = PackedVector2Array()
	for i in range(32):
		var angle = i * TAU / 32
		points.append(Vector2(cos(angle), sin(angle)) * 20)
	ring.polygon = points
	ring.color = Color(1, 0.8, 0.2, 0.8)
	shockwave.add_child(ring)

	# Animate the shockwave
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(shockwave, "scale", Vector2(15, 15), 0.3)
	tween.tween_property(ring, "color:a", 0.0, 0.3)
	tween.chain().tween_callback(shockwave.queue_free)

func is_invincible():
	return invincible_timer > 0 or is_stomping or is_dashing

func cancel_dash():
	if is_dashing:
		is_dashing = false
		invincible_timer = 0.3
