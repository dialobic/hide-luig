extends AnimatedSprite2D

@export var level_name: String = ""
@export var next_level_button: Button = null  # Pulsante del livello successivo da sbloccare
@export var unlock_condition: int = 1  # Numero minimo di bonus per sbloccare (default: 1)

func _ready() -> void:
	add_to_group("bonus_counters")
	
	# Aspetta che l'albero sia pronto
	await get_tree().create_timer(0.05).timeout
	update_display()
	
	# Se next_level_button è impostato, inizializzalo come disabilitato
	if next_level_button:
		next_level_button.disabled = true
		next_level_button.modulate = Color(0.5, 0.5, 0.5, 0.8)  # Scurito per indicare disabilitato

func update_display() -> void:
	if level_name == "":
		return
	
	var bonus_collected = GameState.get_level_progress(level_name)
	bonus_collected = clamp(bonus_collected, 0, 5)
	
	play(str(bonus_collected))
	
	# Sblocca il livello successivo se sono stati raccolti abbastanza bonus
	if next_level_button and bonus_collected >= unlock_condition:
		unlock_next_level()

func unlock_next_level() -> void:
	# Abilita il pulsante del livello successivo
	next_level_button.disabled = false
	next_level_button.modulate = Color(1, 1, 1, 1)  # Torna al colore normale
	
	# Animazione per evidenziare lo sblocco
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(next_level_button, "scale", Vector2(1.05, 1.05), 0.3)
	tween.tween_property(next_level_button, "modulate", Color(1, 1, 0.8, 1), 0.3)
	
	tween.chain().tween_property(next_level_button, "scale", Vector2.ONE, 0.3)
	tween.parallel().tween_property(next_level_button, "modulate", Color(1, 1, 1, 1), 0.3)
	
	print("Level unlocked: ", next_level_button.name)
