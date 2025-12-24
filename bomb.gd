extends Area2D

var speed = 400.0
var direction = 1
var velocity = Vector2.ZERO
var fall_speed = 980.0

var explosion_scene = preload("res://explosion.tscn")

func _ready():
	velocity = Vector2(direction * speed, -300)

func _physics_process(delta):
	velocity.y += fall_speed * delta
	position += velocity * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		explode()
	elif body is StaticBody2D:
		explode()

func explode():
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
