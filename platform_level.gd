extends Node2D

@export var next_level: String = ""
@export var respawn_point: Vector2 = Vector2(100, 400)

@onready var player = $Player

func _ready():
	# Set respawn point for all hazards
	for spike in get_tree().get_nodes_in_group("spikes"):
		spike.respawn_point = respawn_point
	for lava in get_tree().get_nodes_in_group("lava"):
		lava.respawn_point = respawn_point

	# Play music (persists across restarts)
	MusicManager.play_music("res://lava_leap.mp3")

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

func _on_goal_body_entered(body):
	if body.name == "Player":
		if next_level != "":
			get_tree().change_scene_to_file(next_level)
		else:
			# Final level - show win message
			player.set_physics_process(false)
			if has_node("UI/WinLabel"):
				$UI/WinLabel.visible = true
