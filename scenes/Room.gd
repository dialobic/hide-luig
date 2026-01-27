# scenes/Room.gd
extends Node2D

@onready var bg_sprite: Sprite2D = $Background
@onready var objects_container: Node2D = $Objects

var room_key: String
var help_filename: String

func initialize(data: Dictionary, key: String) -> void:
	room_key = key
	help_filename = data.get("help", "")
	
	# Carica background
	var bg_texture = JSONLoader.get_level_texture(GameState.current_level, data.get("image", ""))
	if bg_texture:
		bg_sprite.texture = bg_texture
		bg_sprite.centered = true
		bg_sprite.position = Vector2.ZERO
		
		# Animazione ingresso stanza (come in Phaser)
		bg_sprite.scale = Vector2(0.96, 0.96)
		var tween = create_tween()
		tween.tween_property(bg_sprite, "scale", Vector2.ONE, 0.111) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_QUAD)
	
	# Crea oggetti interattivi
	var objects = data.get("oggetti", [])
	create_objects(objects)

func create_objects(objects_data: Array) -> void:
	# Carica la scena InteractiveObject
	var interactive_scene = preload("res://scenes/InteractiveObject.tscn")
	
	for i in range(objects_data.size()):
		var obj_data = objects_data[i]
		
		if should_show_object(obj_data):
			create_interactive_object(obj_data, interactive_scene)

func should_show_object(data: Dictionary) -> bool:
	# Per ora mostra tutto
	return true
	
func create_interactive_object(data: Dictionary, scene: PackedScene) -> void:
	var interactive_obj = scene.instantiate()
	objects_container.add_child(interactive_obj)
	
	# Setup dell'oggetto
	interactive_obj.setup(data)
	
	# Animazione ingresso oggetto (come in Phaser)
	interactive_obj.scale = Vector2(0.96, 0.96)
	
	# Calcola delay come in Phaser
	var delay = 0.111 + (objects_container.get_child_count() * 0.01)
	
	# Crea tween con delay CORRETTO
	var tween = create_tween()
	tween.tween_property(interactive_obj, "scale", Vector2.ONE, 0.111) \
		.set_delay(delay) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK)
	
	# Collega il segnale di click
	interactive_obj.object_clicked.connect(_on_interactive_object_clicked)

func _on_interactive_object_clicked(obj: Node) -> void:
	# Ora Room è figlia diretta di RoomContainer, che è figlio di GameScene
	var game_scene = get_parent().get_parent()  # Room -> RoomContainer -> GameScene
	if game_scene and game_scene.has_method("handle_object_interaction"):
		game_scene.handle_object_interaction(obj)
