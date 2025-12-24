extends Area2D

var radius = 150.0
var damage = 3
var duration = 0.3

func _ready():
	$Circle.scale = Vector2(radius / 50.0, radius / 50.0)

	# Deal damage to all enemies in radius
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(global_position) < radius:
			enemy.take_damage(damage)

	# Fade out and remove
	var tween = create_tween()
	tween.tween_property($Circle, "modulate:a", 0.0, duration)
	tween.tween_callback(queue_free)
