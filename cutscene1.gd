extends Node2D

@onready var player = $Player
@onready var cavalier = $Cavalier
@onready var dialogue_label = $UI/DialogueLabel
@onready var buildings = $Buildings
@onready var tunnel = $Tunnel
@onready var tunnel_area = $TunnelArea

var cutscene_phase = 0
var cutscene_timer = 0.0
var building_fall_speed = 0.0
var player_can_move = false
var cavalier_jumping = false
var cavalier_velocity = Vector2.ZERO

func _ready():
	player.set_physics_process(false)
	player.get_node("UI/ControlsPanel").visible = false
	tunnel.visible = false
	tunnel.scale = Vector2(0.1, 0.1)
	tunnel_area.monitoring = false
	dialogue_label.text = ""
	cutscene_timer = 1.5

func _process(delta):
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

	run_cutscene(delta)

	# Animate Cuddlepup jumping
	if cavalier_jumping:
		cavalier_velocity.y += 1200.0 * delta
		cavalier.position += cavalier_velocity * delta
		# Land on the ground
		if cavalier.position.y >= 1000:
			cavalier.position.y = 1000
			cavalier_jumping = false
			cavalier_velocity = Vector2.ZERO

func run_cutscene(delta):
	if cutscene_phase >= 10:
		return

	cutscene_timer -= delta

	match cutscene_phase:
		0:  # Carl looks up
			if cutscene_timer <= 0:
				cutscene_phase = 1
				cutscene_timer = 2.0
				dialogue_label.text = "Carl: Are you okay up there?"
		1:  # Carl notices shaking
			if cutscene_timer <= 0:
				cutscene_phase = 2
				cutscene_timer = 2.0
				dialogue_label.text = "Carl: Something's wrong... the ground is shaking!"
		2:  # Rumble warning
			if cutscene_timer <= 0:
				cutscene_phase = 3
				cutscene_timer = 3.0
				dialogue_label.text = "*RUMBLE*"
				building_fall_speed = 50.0
		3:  # Buildings collapse
			building_fall_speed += 500 * delta
			for building in buildings.get_children():
				building.position.y += building_fall_speed * delta
			if cutscene_timer <= 0:
				cutscene_phase = 4
				cutscene_timer = 1.5
				dialogue_label.text = ""
		4:  # Pause after collapse
			if cutscene_timer <= 0:
				cutscene_phase = 5
				cutscene_timer = 2.5
				dialogue_label.text = "Carl: Look! A tunnel!"
				tunnel.visible = true
		5:  # Tunnel opens
			tunnel.scale = tunnel.scale.lerp(Vector2(1.5, 1.5), delta * 2)
			# Warm glow pulsing
			var glow = 0.5 + 0.3 * sin(cutscene_timer * 5)
			tunnel.modulate = Color(1, 0.6 + glow * 0.2, 0.3 + glow * 0.1, 1)
			if cutscene_timer <= 0:
				cutscene_phase = 6
				cutscene_timer = 2.0
				dialogue_label.text = "Carl: It's... warm. Let's go, Cuddlepup!"
				# Cuddlepup jumps down from tree
				cavalier_velocity = Vector2(150, -400)
				cavalier_jumping = true
		6:  # Cuddlepup lands
			if cutscene_timer <= 0:
				cutscene_phase = 7
				cutscene_timer = 1.5
				dialogue_label.text = "Carl: Come on buddy!"
		7:  # Enable player movement
			if cutscene_timer <= 0:
				cutscene_phase = 10
				dialogue_label.text = "[Walk into the tunnel]"
				player.set_physics_process(true)
				player.get_node("UI/ControlsPanel").visible = true
				tunnel_area.monitoring = true
				player_can_move = true

func _on_tunnel_area_body_entered(body):
	if body.name == "Player" and player_can_move:
		get_tree().change_scene_to_file("res://main.tscn")
