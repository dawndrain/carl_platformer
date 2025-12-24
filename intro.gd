extends Node2D

@onready var player = $Player
@onready var npc = $NPC
@onready var dialogue_label = $UI/DialogueLabel
@onready var continue_label = $UI/ContinueLabel

var cutscene_phase = 0
var waiting_for_input = false
var npc_jumping = false
var npc_velocity = Vector2.ZERO
var npc_landed = false

func _ready():
	player.set_physics_process(false)
	player.get_node("UI/ControlsPanel").visible = false
	dialogue_label.text = "*Playing video games*"
	waiting_for_input = true
	continue_label.visible = true

func _process(delta):
	# Level skip
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

	if cutscene_phase < 10:
		run_cutscene(delta)

func _physics_process(delta):
	if npc_jumping and not npc_landed:
		npc_velocity.y += 1500.0 * delta
		npc.position += npc_velocity * delta

		# Land on the tree leaves (visible through window)
		if npc.position.y >= 450:
			npc.position.y = 450
			npc_velocity = Vector2.ZERO
			npc_landed = true
			npc_jumping = false

func run_cutscene(_delta):
	# Wait for space press
	if waiting_for_input:
		if Input.is_action_just_pressed("jump"):
			waiting_for_input = false
			continue_label.visible = false
			advance_dialogue()
		return

func advance_dialogue():
	match cutscene_phase:
		0:  # After "Playing video games"
			cutscene_phase = 1
			npc.visible = true
			npc.position = Vector2(1550, 400)
			# Jump arc into the tree
			npc_velocity = Vector2(-200, -150)
			npc_jumping = true
			dialogue_label.text = "Cuddlepup, what are you doing?"
			waiting_for_input = true
			continue_label.visible = true
		1:  # After Cuddlepup question
			cutscene_phase = 2
			dialogue_label.text = "Cuddlepup jumped out the window, better go after him"
			waiting_for_input = true
			continue_label.visible = true
		2:  # After "better go after him"
			cutscene_phase = 3
			dialogue_label.text = "This better be quick"
			waiting_for_input = true
			continue_label.visible = true
		3:  # After "This better be quick"
			cutscene_phase = 10
			npc.visible = false
			dialogue_label.text = "[Walk to the door on the left]"
			continue_label.visible = false
			player.set_physics_process(true)
			player.get_node("UI/ControlsPanel").visible = true

func _on_exit_area_body_entered(body):
	if body.name == "Player" and cutscene_phase >= 10:
		get_tree().change_scene_to_file("res://cutscene1.tscn")
