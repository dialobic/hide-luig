# scripts/JSONLoader.gd
class_name JSONLoader

static func load_level(level_num: int) -> Dictionary:
	var path = "res://levels/level%d/level%d.json" % [level_num, level_num]
	
	print("Loading JSON from: ", path)
	
	if not FileAccess.file_exists(path):
		printerr("File not found: ", path)
		return {}
	
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	
	if error != OK:
		printerr("JSON Parse Error: ", json.get_error_message())
		return {}
	
	print("JSON parsed successfully")
	return json.data

static func get_level_texture(level_num: int, filename: String) -> Texture2D:
	var path = "res://levels/level%d/%s" % [level_num, filename]
	
	print("Looking for texture: ", path)
	
	if ResourceLoader.exists(path):
		var texture = load(path)
		print("Texture found: ", filename)
		return texture
	
	# Fallback: rimuovi .png se presente
	var filename_no_ext = filename.replace(".png", "")
	path = "res://levels/level%d/%s" % [level_num, filename_no_ext]
	
	if ResourceLoader.exists(path):
		var texture = load(path)
		print("Texture found (without .png): ", filename_no_ext)
		return texture
	
	printerr("Texture not found: ", filename)
	return null

static func get_level_sound(level_num: int, sound_name: String) -> AudioStream:
	print("Loading sound: ", sound_name)
	
	# Prova diverse estensioni e percorsi
	var possible_paths = [
		# Suoni specifici del livello
		"res://levels/level%d/%s.ogg" % [level_num, sound_name],
		"res://levels/level%d/%s.wav" % [level_num, sound_name],
		"res://levels/level%d/%s.mp3" % [level_num, sound_name],
		
		# Suoni negli asset condivisi
		"res://assets/sounds/%s.ogg" % sound_name,
		"res://assets/sounds/%s.wav" % sound_name,
		"res://assets/sounds/%s.mp3" % sound_name,
		
		# Prova anche senza estensione
		"res://levels/level%d/%s" % [level_num, sound_name],
		"res://assets/sounds/%s" % sound_name,
	]
	
	for path in possible_paths:
		if ResourceLoader.exists(path):
			var stream = load(path)
			
			# Configura il stream se necessario
			if stream is AudioStreamOggVorbis:
				stream.loop = false
			elif stream is AudioStreamWAV:
				stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
			
			return stream

	return null
