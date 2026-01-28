# JSONLoader.gd
#extends Node

class_name JSONLoader  # Aggiungi questa riga in cima al file se vuoi usarlo come tipo

static func load_level(level_name: String) -> Dictionary:
	var path = "res://levels/%s/%s.json" % [level_name, level_name]
	
	if not FileAccess.file_exists(path):
		printerr("Level file not found: ", path)
		return {}
	
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	
	if error == OK:
		return json.data
	else:
		printerr("JSON Parse Error: ", json.get_error_message())
		return {}

static func get_level_texture(level_name: String, texture_name: String) -> Texture2D:
	# Prova prima con il percorso completo
	var path = "res://levels/%s/%s" % [level_name, texture_name]
	if ResourceLoader.exists(path):
		return load(path)
	
	# Prova senza estensione
	var texture_name_no_ext = texture_name.replace(".png", "").replace(".jpg", "").replace(".webp", "")
	path = "res://levels/%s/%s.png" % [level_name, texture_name_no_ext]
	if ResourceLoader.exists(path):
		return load(path)
	
	# Prova nella cartella assets generica come fallback
	path = "res://assets/textures/%s" % texture_name
	if ResourceLoader.exists(path):
		return load(path)
	
	printerr("Texture not found: ", texture_name, " for level: ", level_name)
	return null
