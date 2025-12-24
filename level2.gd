extends Node2D

@onready var missile_scene = preload("res://missile.tscn")
@onready var bomb_scene = preload("res://bomb.tscn")
@onready var player = $Player
@onready var sidekick = $Sidekick

func _ready():
	player.spawn_missile.connect(_on_spawn_missile)
	player.spawn_bomb.connect(_on_player_spawn_bomb)
	sidekick.shoot_missile.connect(_on_spawn_missile)

func _process(_delta):
	if get_tree().get_nodes_in_group("enemies").size() == 0:
		get_tree().change_scene_to_file("res://platform0.tscn")

func _on_spawn_missile(pos, direction):
	var missile = missile_scene.instantiate()
	missile.position = pos + Vector2(direction * 40, 0)
	missile.direction = direction
	add_child(missile)

func _on_player_spawn_bomb(pos, direction):
	var bomb = bomb_scene.instantiate()
	bomb.position = pos + Vector2(direction * 30, -10)
	bomb.direction = direction
	add_child(bomb)
