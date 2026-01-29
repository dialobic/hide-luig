# LevelSelectScene.gd
extends Control

func _ready() -> void:
	#print("=== LEVEL SELECT DEBUG ===")
	#print("GameState level_progress: ", GameState.level_progress)
	#print("GameState.get_all_level_progress(): ", GameState.get_all_level_progress())
	
	# Aggiorna tutti i BonusCount dopo un breve delay
	await get_tree().create_timer(0.1).timeout
	update_all_bonus_counts()

func update_all_bonus_counts() -> void:
	#print("Updating all BonusCount displays...")
	for node in get_tree().get_nodes_in_group("bonus_counters"):
		if node.has_method("update_display"):
			node.update_display()

func _on_visibility_changed() -> void:
	if visible:
		update_all_bonus_counts()
