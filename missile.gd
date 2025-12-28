extends Area2D

var speed = 500.0
var direction = 1

func _ready():
	$ColorRect.offset_left = -8
	$ColorRect.offset_right = 8
	$ColorRect.offset_top = -4
	$ColorRect.offset_bottom = 4

func _physics_process(delta):
	position.x += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(1)
		else:
			body.queue_free()
		queue_free()
	elif body is StaticBody2D:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
