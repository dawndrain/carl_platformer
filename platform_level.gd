extends Node2D

@export var next_level: String = ""
@export var respawn_point: Vector2 = Vector2(100, 400)

@onready var player = $Player
@onready var missile_scene = preload("res://missile.tscn")
@onready var bomb_scene = preload("res://bomb.tscn")

var cuddlepup: Sprite2D = null
var cuddlepup_velocity: float = 0.0
var cuddlepup_base_y: float = 0.0
var cuddlepup_gravity: float = 800.0
var cuddlepup_jump_force: float = -350.0

func _ready():
	# Set respawn point for all hazards
	for spike in get_tree().get_nodes_in_group("spikes"):
		spike.respawn_point = respawn_point
	for lava in get_tree().get_nodes_in_group("lava"):
		lava.respawn_point = respawn_point

	# Play music (persists across restarts)
	MusicManager.play_music("res://elevator_shanty_song.mp3")

	# Connect player shooting signals
	player.spawn_missile.connect(_on_spawn_missile)
	player.spawn_bomb.connect(_on_spawn_bomb)

	# Setup Cuddlepup if present
	if has_node("Cuddlepup"):
		cuddlepup = $Cuddlepup
		cuddlepup_base_y = cuddlepup.position.y
		cuddlepup_velocity = cuddlepup_jump_force  # Start jumping

func _process(delta):
	# Animate Cuddlepup jumping
	if cuddlepup:
		cuddlepup_velocity += cuddlepup_gravity * delta
		cuddlepup.position.y += cuddlepup_velocity * delta

		# Land and jump again
		if cuddlepup.position.y >= cuddlepup_base_y:
			cuddlepup.position.y = cuddlepup_base_y
			cuddlepup_velocity = cuddlepup_jump_force

		# Face towards Carl
		cuddlepup.flip_h = player.global_position.x < cuddlepup.global_position.x

	# Level skip keys
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
	if Input.is_key_pressed(KEY_N) and next_level != "":
		get_tree().change_scene_to_file(next_level)

func _on_goal_body_entered(body):
	if body.name == "Player":
		if next_level != "":
			get_tree().change_scene_to_file(next_level)
		else:
			# Final level - show win message
			player.set_physics_process(false)
			if has_node("UI/WinLabel"):
				$UI/WinLabel.visible = true

func _on_spawn_missile(pos, direction):
	var missile = missile_scene.instantiate()
	missile.position = pos + Vector2(direction * 40, 0)
	missile.direction = direction
	add_child(missile)

func _on_spawn_bomb(pos, direction):
	var bomb = bomb_scene.instantiate()
	bomb.position = pos + Vector2(direction * 30, -10)
	bomb.direction = direction
	add_child(bomb)
