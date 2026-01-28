# LevelButton.gd
extends Button

@export var level_name: String = ""  # Nome del livello
@onready var bonus_label: Label = $BonusLabel  # Aggiungi un Label come figlio

func _ready() -> void:
	pressed.connect(_on_pressed)
	update_display()

func _on_pressed() -> void:
	if level_name != "":
		GameState.current_level = level_name
		get_tree().change_scene_to_file("res://scenes/GameScene.tscn")

func update_display() -> void:
	if bonus_label and level_name != "":
		var bonus_collected = GameState.get_level_progress(level_name)
		bonus_label.text = str(bonus_collected)
