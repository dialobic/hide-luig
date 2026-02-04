extends AnimatedSprite2D

@export var level_name: String = ""
@export var next_level_button: Button = null
@export var unlock_condition: int = 1

func _ready() -> void:
	add_to_group("bonus_counters")
	update_display()

func update_display() -> void:
	if level_name == "":
		return
	
	var bonus_collected = GameState.get_level_progress(level_name)
	bonus_collected = clamp(bonus_collected, 0, 5)
	
	play(str(bonus_collected))
	
	if next_level_button and bonus_collected >= unlock_condition:
		unlock_next_level()

func unlock_next_level() -> void:
	next_level_button.disabled = false
	next_level_button.modulate = Color.WHITE
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(next_level_button, "scale", Vector2(1.05, 1.05), 0.3)
	tween.tween_property(next_level_button, "modulate", Color(1, 1, 0.8, 1), 0.3)
	
	tween.chain().tween_property(next_level_button, "scale", Vector2.ONE, 0.3)
	tween.parallel().tween_property(next_level_button, "modulate", Color.WHITE, 0.3)
