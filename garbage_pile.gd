extends Node2D

@onready var garbage_scene = preload("res://garbage.tscn")
@onready var missile_scene = preload("res://missile.tscn")
@onready var bomb_scene = preload("res://bomb.tscn")
@onready var player = $Player
@onready var sidekick = $Sidekick

func _ready():
	player.spawn_missile.connect(_on_spawn_missile)
	player.spawn_bomb.connect(_on_spawn_bomb)
	sidekick.shoot_missile.connect(_on_spawn_missile)

	# Connect boss throw signal
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_signal("throw_garbage"):
			enemy.throw_garbage.connect(_on_throw_garbage)

func _process(_delta):
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

	# Check if boss defeated
	if get_tree() and get_tree().get_nodes_in_group("enemies").size() == 0:
		get_tree().change_scene_to_file("res://thrower_arena.tscn")

func _on_throw_garbage(pos, vel):
	var garbage = garbage_scene.instantiate()
	garbage.position = pos
	garbage.velocity = vel
	add_child(garbage)

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
