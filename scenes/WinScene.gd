# WinScene.gd
extends Node2D

@onready var winframes: AnimatedSprite2D = $WinFrames
@onready var bonus_player: AudioStreamPlayer = $BonusPlayer
@onready var bonus_label: Label = $BonusLabel
@onready var continue_button: TextureButton = $ContinueButton
@onready var animation_timer: Timer = $AnimationTimer

var total_bonus_collected: int = 0
var current_bonus_animation: int = 0
var bonus_shown: int = 0

func _ready() -> void:
	# Ottieni i bonus raccolti nell'ultimo livello
	total_bonus_collected = GameState.collected_bonuses.size()
	
	# Aggiorna la label
	bonus_label.text = "Bonus collected: %d" % total_bonus_collected
	
	# Configura il pulsante (inizialmente nascosto)
	continue_button.pressed.connect(_on_continue_pressed)
	continue_button.visible = false
	continue_button.disabled = true
	
	# Configura l'animazione iniziale
	winframes.play("0")
	current_bonus_animation = 0
	bonus_shown = 0
	
	# Configura il timer
	animation_timer.wait_time = 0.5
	animation_timer.one_shot = false
	animation_timer.timeout.connect(_on_animation_timer_timeout)
	
	# Se non ci sono bonus, salta direttamente alla fine
	if total_bonus_collected == 0:
		animation_timer.wait_time = 3.0
		animation_timer.one_shot = true
		animation_timer.timeout.connect(_show_continue_button)
		animation_timer.start()
	else:
		# Inizia l'animazione dei bonus
		animation_timer.start()

func _on_animation_timer_timeout() -> void:
	if bonus_shown < total_bonus_collected:
		# Mostra il prossimo bonus
		bonus_shown += 1
		current_bonus_animation += 1
		
		# Assicurati che non superiamo il massimo (5)
		if current_bonus_animation > 5:
			current_bonus_animation = 5
		
		# Cambia animazione
		winframes.play(str(current_bonus_animation))
		
		# Suona l'audio
		bonus_player.play()
		
		# Aggiorna la label in tempo reale (opzionale)
		bonus_label.text = "Bonus collected: %d" % bonus_shown
		
	else:
		# Abbiamo mostrato tutti i bonus, ferma il timer
		animation_timer.stop()
		
		# Aspetta 3 secondi e mostra il pulsante
		await get_tree().create_timer(3.0).timeout
		_show_continue_button()

func _show_continue_button() -> void:
	continue_button.visible = true
	continue_button.disabled = false
	
	# Piccola animazione di ingresso per il pulsante
	var tween = create_tween()
	continue_button.modulate.a = 0
	tween.tween_property(continue_button, "modulate:a", 1.0, 0.5)

func _on_continue_pressed() -> void:
	# Torna alla selezione dei livelli
	get_tree().change_scene_to_file("res://scenes/LevelSelectScene.tscn")

# Opzionale: gestisci la visibilità della label bonus
func _process(_delta: float) -> void:
	# Puoi aggiungere effetti visivi qui se vuoi
	pass
