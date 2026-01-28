extends Node2D

@onready var room_container: Node2D = $RoomContainer
@onready var ui_layer: CanvasLayer = $UI
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

func _ready() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	room_container.position = viewport_size / 2
	
	GameState.reset_level_state()
	load_level_data()
	setup_ui()
	set_background_color()
	load_room("001")
	
	GameState.inventory_changed.connect(_on_inventory_changed)

func load_level_data() -> void:
	var data = JSONLoader.load_level(GameState.current_level)
	if data.is_empty():
		printerr("Failed to load level data")
		return
	
	GameState.rooms_data = data
	
	if data.has("config"):
		GameState.set_level_config(data.config)

func set_background_color() -> void:
	var data = JSONLoader.load_level(GameState.current_level)
	if not data.is_empty() and data.has("config") and data.config.has("bg-color"):
		var color_str = data.config["bg-color"]
		var bg_color = Color(color_str)
		RenderingServer.set_default_clear_color(bg_color)

func setup_ui() -> void:
	bonus_label.text = "Bonus: 0/%d" % GameState.win_bonus_count
	bonus_label.visible = false
	exit_button.text = "EXIT"
	exit_button.pressed.connect(_on_exit_pressed)

func load_room(room_key: String) -> void:
	ambient_player.pitch_scale = randf_range(0.95, 1.05)
	ambient_player.play()
	
	var actual_key = room_key
	while actual_key in GameState.replaced_rooms:
		actual_key = GameState.replaced_rooms[actual_key]
	
	# Controlla se la stanza è "win"
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

func _on_item_delivered(item_key: String, target_room: String) -> void:
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
	
	var bg_texture = preload("res://assets/textures/inventario.png")
	if bg_texture:
		inventory_background = Sprite2D.new()
		inventory_background.texture = bg_texture
		inventory_background.centered = true
		inventory_background.position = Vector2(GameState.inventory_x, GameState.inventory_y)
		inventory_background.scale = Vector2.ZERO
		inventory_container.add_child(inventory_background)
		
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
	bonus_label.visible = count > 0

func _on_inventory_changed(item_key: String) -> void:
	pass

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LevelSelectScene.tscn")
