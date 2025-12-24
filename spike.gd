extends Area2D

@export var respawn_point: Vector2 = Vector2(100, 400)

func _on_body_entered(body):
	if body.name == "Player":
		body.position = respawn_point
