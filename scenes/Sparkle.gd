# Sparkle.gd
extends Sprite2D

func appear_at(position: Vector2) -> void:
	visible = true
	global_position = position
	
	# Animazione semplice
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.7, 0.3)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.3)
	
	tween.chain().tween_interval(0.3)
	
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(self, "scale", Vector2(0.7, 0.7), 0.3)
