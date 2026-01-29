# InteractiveObject.gd
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var focus_sprite: Sprite2D = $Focus  # Assicurati che il nodo si chiami "Focus"

const PUFF_SCENE = preload("res://scenes/Puff.tscn") # Precarica la scena Puff

var object_type: String = ""
var target_room: String = ""
var item_name: String = ""
var is_being_removed: bool = false

signal object_clicked(obj)

func setup(data: Dictionary) -> void:
	object_type = data.get("tipo", "")
	target_room = data.get("target", "")
	
	if data.has("item"):
		item_name = data.get("item", "").replace(".png", "")
	
	var texture_path = data.get("icona", "")
	if texture_path:
		var texture = JSONLoader.get_level_texture(GameState.current_level, texture_path)
		if texture:
			sprite.texture = texture
			sprite.centered = true
	
	if data.has("pos") and data.pos is Array and data.pos.size() >= 2:
		var pos_x = data.pos[0]
		var pos_y = data.pos[1]
		position = Vector2(pos_x, pos_y)
	
	var collision = $CollisionShape2D
	var shape = CircleShape2D.new()
	shape.radius = 40.0
	collision.shape = shape

func _ready() -> void:
	input_pickable = true
	
	# Imposta il focus come invisibile all'inizio
	if focus_sprite:
		focus_sprite.modulate.a = 0
		focus_sprite.visible = true
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)

func _on_mouse_entered() -> void:
	if not is_being_removed:
		# Animazione dello sprite principale (ingrandimento)
		var sprite_tween = create_tween()
		sprite_tween.tween_property(sprite, "scale", Vector2(1.05, 1.05), 0.1).set_ease(Tween.EASE_OUT)
				
		# Animazione del focus (fade-in)
		if focus_sprite:
			var focus_tween = create_tween()
			focus_tween.tween_property(focus_sprite, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT)
			
		# Pulsazione leggera (opzionale)
		var pulse_tween = create_tween()
		pulse_tween.set_loops()
		pulse_tween.tween_property(focus_sprite, "scale", Vector2(1.05, 1.05), 0.5)
		pulse_tween.tween_property(focus_sprite, "scale", Vector2.ONE, 0.5)

func _on_mouse_exited() -> void:
	if not is_being_removed:
		# Animazione dello sprite principale (ritorno normale)
		var sprite_tween = create_tween()
		sprite_tween.tween_property(sprite, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_OUT)
		
		# Animazione del focus (fade-out)
		if focus_sprite:
			var focus_tween = create_tween()
			focus_tween.tween_property(focus_sprite, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_OUT)

func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if is_being_removed:
		return
	
	var is_clicked = false
	var click_position = Vector2.ZERO
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		is_clicked = true
		click_position = event.global_position  # Posizione del mouse in coordinate globali
	elif event is InputEventScreenTouch and event.is_pressed():
		is_clicked = true
		# Per i touch, converti in coordinate globali
		click_position = viewport.get_canvas_transform().affine_inverse() * event.position
	
	if is_clicked:
		# Crea l'istanza del Puff
		create_puff_effect(click_position)
		
		# Emetti il segnale per la logica di gioco
		object_clicked.emit(self)

func create_puff_effect(position: Vector2) -> void:
	# Istanzia la scena Puff
	var puff_instance = PUFF_SCENE.instantiate()
	
	# Aggiungila alla scena corrente (nello stesso albero dell'oggetto)
	get_tree().current_scene.add_child(puff_instance)
	
	# Imposta la posizione globale
	puff_instance.global_position = position
	
	# Imposta una rotazione casuale (in radianti)
	puff_instance.rotation = randf() * 2.0 * PI  # Angolo casuale tra 0 e 360 gradi

func animate_collection() -> void:
	is_being_removed = true
	
	# Disabilita ulteriori interazioni
	input_pickable = false
	mouse_entered.disconnect(_on_mouse_entered)
	mouse_exited.disconnect(_on_mouse_exited)
	
	# Anima il focus in uscita se è visibile
	if focus_sprite and focus_sprite.modulate.a > 0:
		var tween = create_tween()
		tween.tween_property(focus_sprite, "modulate:a", 0.0, 0.1)
	
	# ... resto dell'animazione di raccolta
