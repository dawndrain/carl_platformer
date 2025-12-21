extends Node2D

@onready var missile_scene = preload("res://missile.tscn")
@onready var player = $Player

func _ready():
	player.spawn_missile.connect(_on_player_spawn_missile)

func _on_player_spawn_missile(pos, direction):
	var missile = missile_scene.instantiate()
	missile.position = pos + Vector2(direction * 40, 0)
	missile.direction = direction
	add_child(missile)
