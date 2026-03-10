extends Node

var save_game_path = "user://save_games/"

var save_games = []
var loaded_restore_index = 0

func _ready():
	#print("User dir", OS.get_user_data_dir())
	#_remove_all_files()
	pass
	
func _remove_all_files():
	if not FilesUtil.dir_exists(save_game_path):
		FilesUtil.create_dir(save_game_path)
	var files = FilesUtil.get_files_at(save_game_path)
	for file in files:
		if file.begins_with("save_game_"):
			FilesUtil.remove_file(str(save_game_path, file))
		if file.begins_with("save_persisting_nodes_"):
			FilesUtil.remove_file(str(save_game_path, file))

func find_save_game_index(description: String):
	var index = 1
	var saves = get_save_games()
	for s in saves:
		if s.description == description:
			return index
		index += 1
	return index

func get_save_games():
	var saves = []
	for file in DirAccess.get_files_at(save_game_path):
		if file.begins_with("save_game_"):
			var index = file.get_file().get_basename().get_slice("_", 2)
			var path = str(save_game_path, "save_game_", index, ".dat")
			var data = FilesUtil.restore(path)
			saves.append(data)
	saves.sort_custom(func(a, b): return a.index > b.index)
	return saves

func get_next_save_game_index():
	var index = 0
	for file in DirAccess.get_files_at(save_game_path):
		if file.begins_with("save_game_"):
			var index_str = file.get_file().get_basename().get_slice("_", 2)
			if index_str.is_valid_int():
				index = max(index, index_str.to_int())
	return index + 1

func save(description: String):
	var index = get_next_save_game_index()
	var path = str(save_game_path, "save_game_", index, ".dat")
	var data = {
		"index": index,
		"description": description,
		"scene_path": SceneManager.current_scene.scene_file_path,
		"game_state_store": GameStateStore.save(),
		"quest_manager": QuestManager.save(),
		"timestamp": Time.get_datetime_string_from_system(false, true)
	}
	FilesUtil.save(path, data)
	save_persisting_nodes(index)
	
func restore(index):
	loaded_restore_index = index
	var path = str(save_game_path, "save_game_", index, ".dat")
	var data = FilesUtil.restore(path)
	GameStateStore.restore(data.game_state_store)
	QuestManager.restore(data.quest_manager)
	UiManager.game_menus.pop_all()
	GameManager.unpause()
	SceneManager.goto_scene(data.scene_path)
	
func get_restore_data(scene_path: String):
	var data = get_persisting_nodes(loaded_restore_index)
	if data:
		for node in data:
			if node.path == scene_path:
				return node
	return null

func save_persisting_nodes(index):
	var path = str(save_game_path, "save_persisting_nodes_", index, ".dat")
	var file = FilesUtil.open_file(path)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")
		
#		# Store the save dictionary as a new line in the save file.
		file.store_line(JSON.stringify(node_data))
		
func get_persisting_nodes(index):
	var path = str(save_game_path, "save_persisting_nodes_", index, ".dat")
	if not FilesUtil.file_exists(path):
		return
	var file = FilesUtil.open_file(path, FileAccess.READ)
	var nodes = []
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	while file.get_position() < file.get_length():
		var json = JSON.new()
		var line = file.get_line()
		# Get the saved dictionary from the next line in the save file
		var error = json.parse(line)
		if error == OK:
			var node_data = json.get_data()
			nodes.append(node_data)
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", line, " at line ", json.get_error_line())
	return nodes
