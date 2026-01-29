extends Button

@export var level_name: String = ""  # Nome del livello
@export var color_to_bg: Color = Color("70cf9e") # Colore che sostituirà il Teal
@export var color_to_fg: Color = Color("e98b00") # Colore che sostituirà il Giallo

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if level_name != "":
		# 1. Scriviamo i colori scelti nel GameState prima di cambiare scena
		GameState.color_bg = color_to_bg
		GameState.color_fg = color_to_fg
		
		# 2. Impostiamo il livello corrente
		GameState.current_level = level_name
		
		# 3. Cambiamo scena
		get_tree().change_scene_to_file("res://scenes/GameScene.tscn")
