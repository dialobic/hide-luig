# scenes/InventoryItem.gd
class_name InventoryItem
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var item_key: String = ""
var current_tween: Tween = null

func initialize(item_texture: Texture2D, item_key: String) -> void:
	self.item_key = item_key
	sprite.texture = item_texture
	sprite.centered = true
	
	# Imposta scala iniziale piccola
	scale = Vector2(0.9, 0.9)
	visible = false

func animate_to_inventory(start_pos: Vector2, inventory_pos: Vector2) -> void:
	visible = true
	position = start_pos
	
	# Ferma eventuali tween precedenti
	if current_tween:
		current_tween.kill()
	
	# Crea nuovo tween
	current_tween = create_tween()
	current_tween.set_parallel(true)
	current_tween.tween_property(self, "position", inventory_pos, 0.555)
	current_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.555)
	current_tween.tween_property(self, "rotation", TAU, 0.555)  # 360 gradi
	
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.set_trans(Tween.TRANS_CUBIC)

func animate_to_target(target_pos: Vector2, callback: Callable) -> void:
	# Ferma eventuali tween precedenti
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.set_parallel(true)
	current_tween.tween_property(self, "position", target_pos, 0.555)
	current_tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.555)
	current_tween.tween_property(self, "rotation", rotation + TAU, 0.555)	
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.set_trans(Tween.TRANS_CUBIC)
	current_tween.finished.connect(callback)
