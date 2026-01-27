# scripts/GameState.gd
extends Node

# === STATE ===
var current_level: int = 1
var rooms_data: Dictionary = {}
var replaced_rooms: Dictionary = {}
var collected_bonuses: Array = []
var inventory_item: String = ""  # Item key (senza .png)

# === LEVEL CONFIG ===
var level_background_color: Color = Color.TRANSPARENT
var win_bonus_count: int = 5

# === UI POSITIONS (in pixel, relative allo schermo) ===
var inventory_x: int = 898  # Posizione X inventario
var inventory_y: int = 100  # Posizione Y inventario

# === SIGNALS ===
signal inventory_changed(item_key)
signal bonus_collected(bonus_id)

func reset_level_state() -> void:
	replaced_rooms.clear()
	collected_bonuses.clear()
	inventory_item = ""
	level_background_color = Color.TRANSPARENT
	inventory_changed.emit("")  # Notifica che l'inventario è vuoto

func set_level_config(config: Dictionary) -> void:
	if config.has("bg-color"):
		var color_str = config["bg-color"]
		level_background_color = Color(color_str)
	if config.has("win_bonus_count"):
		win_bonus_count = config.win_bonus_count
