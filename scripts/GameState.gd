# GameState.gd
extends Node

# === CURRENT LEVEL ===
var current_level: String = ""

# === LEVEL DATA ===
var rooms_data: Dictionary = {}
var replaced_rooms: Dictionary = {}
var collected_bonuses: Array = []
var inventory_item: String = ""
var used_items = {}

# === CONFIG ===
var color_bg : Color = Color("ffcc99ff")
var color_fg : Color = Color("ffa35cff")
var win_bonus_count: int = 5

# === UI POSITIONS ===
var inventory_x: int = 1020
var inventory_y: int = 150

# === PROGRESS ===
var level_progress: Dictionary = {}  # Formato: { "level_name": bonus_collected }

# === SIGNALS ===
signal inventory_changed(item_key)
signal bonus_collected(bonus_id)

func _ready() -> void:
	load_progress()
	#print("Progress loaded on startup: ", level_progress)

func mark_item_as_used(item_key: String) -> void:
	used_items[item_key] = true

func reset_level_state() -> void:
	replaced_rooms.clear()
	collected_bonuses.clear()
	inventory_item = ""
	inventory_changed.emit("")
	used_items.clear()

func set_level_config(config: Dictionary) -> void:
	if config.has("win_bonus_count"):
		win_bonus_count = config.win_bonus_count

func save_level_progress(level_name: String, bonus_collected: int) -> void:
	# Salva i progressi per questo livello
	level_progress[level_name] = bonus_collected
	save_to_file()
	#print("Progress saved: ", level_name, " -> ", bonus_collected, " bonus")

func get_level_progress(level_name: String) -> int:
	# Restituisce il numero di bonus raccolti per un livello (0 se non presente)
	return level_progress.get(level_name, 0)

func load_progress() -> void:
	# Carica i progressi dal file
	var file_path = "user://progress.save"
	
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var data = file.get_var()
			if typeof(data) == TYPE_DICTIONARY:
				level_progress = data
				#print("Loaded progress from file: ", level_progress)
			else:
				print("Invalid save data format")
			file.close()
	else:
		print("No save file found, starting fresh")
		level_progress = {}

func save_to_file() -> void:
	# Salva i progressi su file
	var file = FileAccess.open("user://progress.save", FileAccess.WRITE)
	if file:
		file.store_var(level_progress)
		file.close()
		#print("Progress saved to file")

func get_all_level_progress() -> Dictionary:
	# Restituisce tutti i progressi
	return level_progress

func clear_all_progress() -> void:
	# Funzione di debug: cancella tutti i progressi
	level_progress.clear()
	save_to_file()
	#print("All progress cleared")
