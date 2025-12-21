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
var is_stomping = false
var invincible_timer = 0.0

signal spawn_missile(pos, direction)

func _process(_delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _physics_process(delta):
	dash_cooldown = max(0, dash_cooldown - delta)
	teleport_cooldown = max(0, teleport_cooldown - delta)
	missile_cooldown = max(0, missile_cooldown - delta)
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
		move_and_slide()
		if is_on_floor():
			is_stomping = false
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

func start_stomp():
	is_stomping = true
	velocity = Vector2.ZERO

func stomp_land():
	invincible_timer = 0.5
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(global_position) < 200:
			enemy.take_damage(2)

func is_invincible():
	return invincible_timer > 0 or is_stomping or is_dashing

func cancel_dash():
	if is_dashing:
		is_dashing = false
		invincible_timer = 0.3
