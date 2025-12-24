extends Node2D

@onready var rock_scene = preload("res://rock.tscn")
@onready var missile_scene = preload("res://missile.tscn")
@onready var bomb_scene = preload("res://bomb.tscn")
@onready var player = $Player
@onready var sidekick = $Sidekick

func _ready():
	# Connect player attack signals
	player.spawn_missile.connect(_on_spawn_missile)
	player.spawn_bomb.connect(_on_spawn_bomb)
	sidekick.shoot_missile.connect(_on_spawn_missile)

	# Connect all thrower signals
	for thrower in get_tree().get_nodes_in_group("enemies"):
		if thrower.has_signal("throw_rock"):
			thrower.throw_rock.connect(_on_thrower_throw_rock)

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

	# Check if all enemies defeated
	if get_tree() and get_tree().get_nodes_in_group("enemies").size() == 0:
		get_tree().change_scene_to_file("res://tentacle_arena.tscn")

func _on_thrower_throw_rock(pos, vel):
	var rock = rock_scene.instantiate()
	rock.position = pos
	rock.velocity = vel
	add_child(rock)

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
