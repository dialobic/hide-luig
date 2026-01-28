# GameState.gd
extends Node

# === CURRENT LEVEL ===
var current_level: String = ""

# === LEVEL DATA ===
var rooms_data: Dictionary = {}
var replaced_rooms: Dictionary = {}
var collected_bonuses: Array = []
var inventory_item: String = ""

# === CONFIG ===
var level_background_color: Color = Color.TRANSPARENT
var win_bonus_count: int = 5

# === UI POSITIONS ===
var inventory_x: int = 898
var inventory_y: int = 100

# === PROGRESS ===
var level_progress: Dictionary = {}

# === SIGNALS ===
signal inventory_changed(item_key)
signal bonus_collected(bonus_id)

func _ready() -> void:
	load_progress()

func reset_level_state() -> void:
	replaced_rooms.clear()
	collected_bonuses.clear()
	inventory_item = ""
	level_background_color = Color.TRANSPARENT
	inventory_changed.emit("")

func set_level_config(config: Dictionary) -> void:
	if config.has("bg-color"):
		var color_str = config["bg-color"]
		level_background_color = Color(color_str)
	if config.has("win_bonus_count"):
		win_bonus_count = config.win_bonus_count

func save_level_progress(level_name: String, bonus_collected: int) -> void:
	level_progress[level_name] = bonus_collected
	print("Progress saved: ", level_name, " - ", bonus_collected, " bonus")

func get_level_progress(level_name: String) -> int:
	return level_progress.get(level_name, 0)

func load_progress() -> void:
	if FileAccess.file_exists("user://savegame.dat"):
		var file = FileAccess.open("user://savegame.dat", FileAccess.READ)
		if file:
			var data = file.get_var()
			level_progress = data if typeof(data) == TYPE_DICTIONARY else {}
			file.close()
