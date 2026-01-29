extends Node2D

@onready var room_container: Node2D = $RoomContainer
@onready var ui_layer: CanvasLayer = $UI
@onready var help_button: TextureButton = $UI/Help
@onready var help_overlay: Sprite2D = $UI/HelpOverlay
@onready var message_label: Label = $UI/HelpOverlay/MessageLabel
@onready var yes_button: Button = $UI/HelpOverlay/HelpContent/YesButton
@onready var no_button: Button = $UI/HelpOverlay/HelpContent/NoButton
@onready var help_image: Sprite2D = $UI/HelpOverlay/HelpImage
@onready var ok_button: Button = $UI/HelpOverlay/HelpContent/OKButton
@onready var bonus_label: Label = $UI/BonusCounter
@onready var exit_button: Button = $UI/ExitButton
@onready var inventory_container: Node2D = $UI/InventoryContainer
@onready var ambient_player = $SoundPool/AmbientPlayer
@onready var click_player = $SoundPool/ClickPlayer
@onready var bonus_player = $SoundPool/BonusPlayer
@onready var done_player = $SoundPool/DonePlayer
@onready var take_player = $SoundPool/TakePlayer
@onready var woosh_player = $SoundPool/WooshPlayer
@onready var wrong_player = $SoundPool/WrongPlayer

var current_room: Node = null
var inventory_item_node: InventoryItem = null
var inventory_background: Sprite2D = null
var sparkle: Sprite2D = null
var sparkle_timer: Timer = null
var sparkle_target_index: int = 0
var current_help_image: String = ""
var overlay_mode: String = ""  # "help" o "exit"

func _ready() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	room_container.position = viewport_size / 2
	
	GameState.reset_level_state()
	load_level_data()
	setup_ui()
	load_room("001")
	setup_sparkle_system()
	setup_help_system()

func setup_help_system() -> void:
	help_button.visible = false
	help_button.pressed.connect(_on_help_button_pressed)
	
	help_overlay.visible = false
	yes_button.pressed.connect(_on_yes_pressed)
	no_button.pressed.connect(_on_no_pressed)
	ok_button.pressed.connect(_on_ok_pressed)
	
	help_image.visible = false
	ok_button.visible = false
	
func _on_exit_button_pressed() -> void:
	# Imposta la modalità exit
	overlay_mode = "exit"
	exit_button.visible = false
	help_button.visible = false
	
	# Mostra l'overlay con il messaggio di conferma
	help_overlay.visible = true
	message_label.text = "abandon the seek?"
	message_label.visible = true
	
	# Mostra i bottoni YES/NO (nascondi OK e l'immagine di help)
	yes_button.visible = true
	no_button.visible = true
	help_image.visible = false
	ok_button.visible = false
	
	# Disabilita le interazioni con il gioco
	set_process_input(false)

func _on_help_button_pressed() -> void:
	# Imposta la modalità help
	overlay_mode = "help"
	help_overlay.visible = true
	help_button.visible = false
	exit_button.visible = false
	
	message_label.text = "Need a little HELP?"
	message_label.visible = true
	yes_button.visible = true
	no_button.visible = true
	help_image.visible = false
	ok_button.visible = false
	
	# Disabilita le interazioni con il gioco
	set_process_input(false)

func _on_yes_pressed() -> void:
	match overlay_mode:
		"help":
			# Comportamento originale per l'help
			message_label.visible = false
			yes_button.visible = false
			no_button.visible = false
			
			if current_help_image != "":
				var texture = JSONLoader.get_level_texture(GameState.current_level, current_help_image)
				if texture:
					help_image.texture = texture
					help_image.visible = true
			
			ok_button.visible = true
		
		"exit":
			# Torna alla scena di selezione dei livelli
			get_tree().change_scene_to_file("res://scenes/LevelSelectScene.tscn")

func _on_no_pressed() -> void:
	# Chiude l'overlay
	help_overlay.visible = false
	exit_button.visible = true
	
	# Gestisci la visibilità del bottone Help in base alla modalità
	match overlay_mode:
		"help":
			if current_help_image != "":
				help_button.visible = true
		"exit":
				# Riprendi la visibilità del bottone Help (se c'è un help in questa stanza)
				if current_help_image != "":
					help_button.visible = true

	
	# Reset della modalità
	overlay_mode = ""
	
	# Riabilita le interazioni
	set_process_input(true)

func _on_ok_pressed() -> void:
	# Chiude l'overlay
	help_overlay.visible = false
	
	# Riprendi la visibilità del bottone Help (se c'è un help in questa stanza)
	if current_help_image != "":
		help_button.visible = true
	
	# Reset della modalità
	overlay_mode = ""
	
	# Riabilita le interazioni
	set_process_input(true)
	exit_button.visible = true


func setup_sparkle_system() -> void:
	var sparkle_scene = preload("res://scenes/Sparkle.tscn")
	sparkle = sparkle_scene.instantiate()
	ui_layer.add_child(sparkle)
	
	sparkle_timer = Timer.new()
	sparkle_timer.wait_time = 3.0
	sparkle_timer.autostart = true
	sparkle_timer.timeout.connect(_on_sparkle_timer_timeout)
	add_child(sparkle_timer)
	
	call_deferred("_on_sparkle_timer_timeout")

func _on_sparkle_timer_timeout() -> void:
	var all_objects = room_container.get_children()
	if all_objects.size() == 0:
		return
	
	var current_room = all_objects[0]
	var interactive_objects = _find_all_interactive_objects(current_room)
	
	if interactive_objects.size() == 0:
		return
	
	sparkle_target_index = (sparkle_target_index + 1) % interactive_objects.size()
	var target_object = interactive_objects[sparkle_target_index]
	var sparkle_position = target_object.global_position + Vector2(0, -9)
	sparkle.appear_at(sparkle_position)

func _find_all_interactive_objects(node: Node) -> Array:
	var objects = []
	
	if node is Area2D and node.has_method("setup"):
		var is_being_removed = node.get("is_being_removed")
		if not is_being_removed or is_being_removed == false:
			objects.append(node)
	
	for child in node.get_children():
		objects.append_array(_find_all_interactive_objects(child))
	
	return objects

func load_level_data() -> void:
	var data = JSONLoader.load_level(GameState.current_level)
	if data.is_empty():
		printerr("Failed to load level data")
		return
	
	GameState.rooms_data = data
	
	if data.has("config"):
		GameState.set_level_config(data.config)

func setup_ui() -> void:
	bonus_label.text = "Bonus: 0/%d" % GameState.win_bonus_count
	# bonus_label.visible = false
	exit_button.text = "EXIT"
	exit_button.pressed.connect(_on_exit_button_pressed)

func load_room(room_key: String) -> void:
	ambient_player.pitch_scale = randf_range(0.95, 1.05)
	ambient_player.play()
	
	var actual_key = room_key
	while actual_key in GameState.replaced_rooms:
		actual_key = GameState.replaced_rooms[actual_key]
	
	if actual_key == "win":
		handle_win_room()
		return
	
	if current_room:
		current_room.queue_free()
		current_room = null
	
	if not GameState.rooms_data.has("stanze"):
		printerr("No 'stanze' key in level data")
		return
	
	if not GameState.rooms_data.stanze.has(actual_key):
		printerr("Room not found: ", actual_key)
		return
	
	var room_scene = preload("res://scenes/Room.tscn")
	current_room = room_scene.instantiate()
	room_container.add_child(current_room)
	
	var room_data = GameState.rooms_data.stanze[actual_key].duplicate(true)
	
	if room_data.has("oggetti"):
		var oggetti = room_data.oggetti
		var filtered_oggetti = []
		for oggetto in oggetti:
			if oggetto.get("tipo") == "bonus":
				var bonus_id = oggetto.get("item")
				if bonus_id and GameState.collected_bonuses.has(bonus_id):
					continue
			
			if oggetto.get("tipo") == "prendi":
				var item_id = oggetto.get("item")
				if item_id and GameState.inventory_item == item_id.replace(".png", ""):
					continue
			
			filtered_oggetti.append(oggetto)
		
		room_data.oggetti = filtered_oggetti
	
	current_room.initialize(room_data, actual_key)
	
	if room_data.has("help"):
		current_help_image = room_data["help"]
		help_button.call_deferred("set", "visible", true)
	else:
		current_help_image = ""
		help_button.call_deferred("set", "visible", false)
	
	sparkle_target_index = 0

func handle_win_room() -> void:
	var bonus_collected = GameState.collected_bonuses.size()
	GameState.save_level_progress(GameState.current_level, bonus_collected)
	get_tree().change_scene_to_file("res://scenes/WinScene.tscn")

func handle_object_interaction(obj: Node) -> void:
	click_player.pitch_scale = randf_range(0.95, 1.05)
	click_player.play()
	
	match obj.object_type:
		"porta":
			load_room(obj.target_room)
		
		"prendi":
			pick_up_item(obj.item_name, obj.global_position, obj)
		
		"metti":
			if GameState.inventory_item == obj.item_name:
				use_item(obj.item_name, obj.global_position, obj.target_room)
			else:
				wrong_player.pitch_scale = randf_range(0.95, 1.05)
				wrong_player.play()
		
		"bonus":
			collect_bonus(obj.item_name, obj)

func pick_up_item(item_key: String, start_pos: Vector2, obj: Node) -> void:
	if GameState.inventory_item != "":
		clear_inventory()
	
	GameState.inventory_item = item_key
	GameState.inventory_changed.emit(item_key)
	
	obj.queue_free()
	
	create_inventory_item(item_key, start_pos)
	
	take_player.pitch_scale = randf_range(0.95, 1.05)
	take_player.play()

func use_item(item_key: String, target_pos: Vector2, target_room: String) -> void:
	if not inventory_item_node:
		return
	
	inventory_item_node.animate_to_target(target_pos, 
		func(): 
			_on_item_delivered(item_key, target_room)
	)
	
	woosh_player.pitch_scale = randf_range(0.95, 1.05)
	woosh_player.play()

func _on_item_delivered(_item_key: String, target_room: String) -> void:
	if current_room:
		GameState.replaced_rooms[current_room.room_key] = target_room
	
	clear_inventory()
	
	done_player.pitch_scale = randf_range(0.95, 1.05)
	done_player.play()
	
	load_room(target_room)

func create_inventory_item(item_key: String, start_pos: Vector2) -> void:
	var inventory_scene = preload("res://scenes/InventoryItem.tscn")
	inventory_item_node = inventory_scene.instantiate()
	inventory_container.add_child(inventory_item_node)
	
	var texture = JSONLoader.get_level_texture(GameState.current_level, item_key + ".png")
	if not texture:
		texture = JSONLoader.get_level_texture(GameState.current_level, item_key)
	
	if texture:
		inventory_item_node.initialize(texture, item_key)
		var inventory_pos = Vector2(GameState.inventory_x, GameState.inventory_y)
		inventory_item_node.animate_to_inventory(start_pos, inventory_pos)
		show_inventory_background()

func show_inventory_background() -> void:
	if inventory_background:
		return
	
	var bg_texture = preload("res://assets/ui/inventario.png")
	if bg_texture:
		inventory_background = Sprite2D.new()
		inventory_background.texture = bg_texture
		inventory_background.centered = true
		inventory_background.position = Vector2(GameState.inventory_x, GameState.inventory_y)
		inventory_container.add_child(inventory_background)
		
		inventory_background.scale = Vector2.ZERO
		var tween = create_tween()
		tween.tween_property(inventory_background, "scale", Vector2.ONE, 0.222) \
			.set_delay(0.5) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_BACK)

func clear_inventory() -> void:
	if inventory_item_node:
		inventory_item_node.queue_free()
		inventory_item_node = null
	
	GameState.inventory_item = ""
	GameState.inventory_changed.emit("")
	
	if inventory_background:
		inventory_background.queue_free()
		inventory_background = null

func collect_bonus(bonus_id: String, bonus_obj: Node) -> void:
	if not bonus_id in GameState.collected_bonuses:
		GameState.collected_bonuses.append(bonus_id)
		GameState.bonus_collected.emit(bonus_id)
		bonus_player.pitch_scale = randf_range(0.95, 1.05)
		bonus_player.play()
		update_bonus_counter()
		
		var bonus_sprite = bonus_obj.get_node("Sprite2D")
		var bonus_texture = bonus_sprite.texture if bonus_sprite else null
		var bonus_global_pos = bonus_sprite.global_position if bonus_sprite else bonus_obj.global_position
		
		bonus_obj.queue_free()
		
		if bonus_texture:
			create_bonus_animation(bonus_texture, bonus_global_pos)

func create_bonus_animation(texture: Texture2D, position: Vector2) -> void:
	var anim_sprite = Sprite2D.new()
	anim_sprite.texture = texture
	anim_sprite.centered = true
	anim_sprite.position = position
	
	add_child(anim_sprite)
	
	var tween = create_tween()
	tween.tween_property(anim_sprite, "position:y", anim_sprite.position.y - 80, 0.5)
	tween.parallel().tween_property(anim_sprite, "modulate:a", 0.0, 0.5)
	tween.tween_callback(anim_sprite.queue_free)

func update_bonus_counter() -> void:
	var count = GameState.collected_bonuses.size()
	bonus_label.text = "Bonus: %d/%d" % [count, GameState.win_bonus_count]
	# bonus_label.visible = count > 0
