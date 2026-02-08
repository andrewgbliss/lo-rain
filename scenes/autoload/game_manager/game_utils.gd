class_name GameUtils extends Node

static func save(path: String, data):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	file.store_string(json_string)
	file.close()

static func restore(path: String):
	_verify_save_dir(path)
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var json_string = file.get_as_text()
		var parse_res = JSON.parse_string(json_string)
		if parse_res:
			return parse_res
		else:
			print("Failed to parse game data")
		file.close()
	else:
		print("Failed to load game data")
	
static func _verify_save_dir(path):
	if not FileAccess.file_exists(path):
		DirAccess.make_dir_absolute(path)

static func _get_json_from_file(path: String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		var parse_res = JSON.parse_string(json_string)
		return parse_res
	else:
		return null

static func remove_file(path: String):
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
