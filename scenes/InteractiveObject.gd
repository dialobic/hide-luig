extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

var object_type: String = ""
var target_room: String = ""
var item_name: String = ""

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
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)

func _on_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 0.1).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_OUT)

func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		object_clicked.emit(self)
	elif event is InputEventScreenTouch and event.is_pressed():
		object_clicked.emit(self)
