extends Button

@export var level_name: String = ""
@onready var bonus_animation: AnimatedSprite2D = $BonusCount

func _ready() -> void:
	pressed.connect(_on_pressed)
	update_bonus_animation()

func update_bonus_animation() -> void:
	if not bonus_animation:
		return
	
	# Leggi i progressi CORRENTI da GameState (già in memoria)
	var bonus_collected = GameState.level_progress.get(level_name, 0)
	
	print("Livello: ", level_name, " - Bonus: ", bonus_collected)
	
	# Ferma l'animazione corrente e imposta quella corretta
	bonus_animation.stop()
	bonus_animation.play(str(bonus_collected))

func _on_pressed() -> void:
	if level_name != "":
		GameState.current_level = level_name
		get_tree().change_scene_to_file("res://scenes/GameScene.tscn")
