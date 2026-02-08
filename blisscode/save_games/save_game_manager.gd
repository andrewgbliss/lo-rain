extends Node

@export var line_edit: LineEdit
@export var save_button: Button
@export var save_game_button_container: VBoxContainer
@export var animation_player: AnimationPlayer
@export var cancel_button_save: Button
@export var cancel_button_restore: Button
@export var play_game_scene: String = "res://scenes/rooms/long_road.tscn"

enum SaveGameMode {NONE, SAVE, RESTORE}

var save_game_mode = SaveGameMode.NONE
var save_games = []
var loaded_restore_index = 0

func _ready():
	SceneManager.loaded.connect(_on_loaded)
	_remove_all_files()
	_update_ui()
	reset()

func _input(event):
	if save_game_mode == SaveGameMode.NONE:
		if event is InputEventKey and event.is_pressed() and not event.is_echo():
			if event.is_action_pressed("save"):
				show_save()
			elif event.is_action_pressed("restore"):
				show_restore()
	elif save_game_mode == SaveGameMode.SAVE:
		if event is InputEventKey and event.is_pressed() and not event.is_echo():
			if event.is_action_pressed("ui_cancel"):
				hide_save()
	elif save_game_mode == SaveGameMode.RESTORE:
		if event is InputEventKey and event.is_pressed() and not event.is_echo():
			if event.is_action_pressed("ui_cancel"):
				hide_restore()

func show_save():
	GameManager.pause()
	save_game_mode = SaveGameMode.SAVE
	animation_player.play("show_save")
	await animation_player.animation_finished
	line_edit.grab_focus()
	line_edit.text = ""
	
func show_restore(pause: bool = true):
	if pause:
		GameManager.pause()
	var saves = _update_ui()
	if saves.size() == 0:
		cancel_button_restore.grab_focus()
	save_game_mode = SaveGameMode.RESTORE
	animation_player.play("show_restore")

func hide_save():
	GameManager.unpause()
	save_game_mode = SaveGameMode.NONE
	animation_player.play("hide_save")
	
func hide_restore():
	GameManager.unpause()
	save_game_mode = SaveGameMode.NONE
	animation_player.play("hide_restore")

func restart():
	reset()
	await SceneManager.goto_scene(play_game_scene)

func _on_loaded():
	save_game_mode = SaveGameMode.NONE
	if GameManager.game_data.restoring_scene:
		await get_tree().create_timer(1.0).timeout
		load_persisting_nodes(loaded_restore_index)
		GameManager.unpause()
		SceneManager.transition_out()
		GameManager.game_data.restoring_scene = false

func _remove_all_files():
	var files = DirAccess.get_files_at("user://")
	for file in files:
		if file.begins_with("save_game_"):
			var dir = DirAccess.open("user://")
			dir.remove(file)
		if file.begins_with("save_persisting_nodes_"):
			var dir = DirAccess.open("user://")
			dir.remove(file)

func _update_ui():
	for child in save_game_button_container.get_children():
		child.queue_free()
	var saves = _get_save_games()
	for s in saves:
		_add_button_to_container(s.description)
	return saves

func _add_button_to_container(description: String):
	var button = Button.new()
	button.text = description
	button.pressed.connect(func _connect(): _on_restore_game_pressed(description))
	save_game_button_container.add_child(button)

func _find_save_game_index(description: String):
	var index = 1
	var saves = _get_save_games()
	for s in saves:
		if s.description == description:
			return index
		index += 1
	return index

func _get_save_games():
	var saves = []
	for file in DirAccess.get_files_at("user://"):
		if file.begins_with("save_game_"):
			var index = file.get_file().get_basename().get_slice("_", 2)
			var path = str("user://save_game_", index, ".dat")
			var data = GameUtils.restore(path)
			saves.append(data)
	return saves

func _get_next_save_game_index():
	var index = 0
	for file in DirAccess.get_files_at("user://"):
		if file.begins_with("save_game_"):
			var index_str = file.get_file().get_basename().get_slice("_", 2)
			if index_str.is_valid_int():
				index = max(index, index_str.to_int())
	return index + 1

func save(description: String):
	var index = _get_next_save_game_index()
	var path = str("user://save_game_", index, ".dat")
	var data = {
		"index": index,
		"description": description,
		"game_data": GameManager.save(),
		"inventory": InventoryManager.save(),
		"quests": QuestManager.save(),
		"timestamp": Time.get_datetime_string_from_system(false, true)
	}
	GameUtils.save(path, data)
	save_persisting_nodes(index)
	
func restore(index):
	var path = str("user://save_game_", index, ".dat")
	var data = GameUtils.restore(path)
	GameManager.restore(data)
	if data.inventory:
		InventoryManager.restore(data.inventory)
	if data.quests:
		QuestManager.restore(data.quests)
	if data.game_data.current_scene_path == get_tree().current_scene.scene_file_path:
		load_persisting_nodes(index)
		GameManager.unpause()
	else:
		GameManager.game_data.restoring_scene = true
		MenuManager.pop_all()
		SceneManager.goto_scene(data.game_data.current_scene_path)
	animation_player.play("hide_restore")
	save_game_mode = SaveGameMode.NONE
	
func reset():
	GameManager.reset()
	QuestManager.reset()
	InventoryManager.reset()

func save_persisting_nodes(index):
	var path = str("user://save_persisting_nodes_", index, ".dat")
	var file = FileAccess.open(path, FileAccess.WRITE)
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
		
func load_persisting_nodes(index):
	var path = str("user://save_persisting_nodes_", index, ".dat")
	if not FileAccess.file_exists(path):
		return
	var file = FileAccess.open(path, FileAccess.READ)
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	while file.get_position() < file.get_length():
		var json = JSON.new()
		var line = file.get_line()
		# Get the saved dictionary from the next line in the save file
		var error = json.parse(line)
		if error == OK:
			var node_data = json.get_data()
			var node = get_node(node_data.get("path"))
			if node != null:
				var new_position = Vector2(node_data.get("pos_x"), node_data.get("pos_y"))
				node.position = new_position
				# Now we set the remaining variables.
				for i in node_data.keys():
					if i == "filename" or i == "parent" or i == "path" or i == "pos_x" or i == "pos_y" or i == "input_x" or i == "input_y" or i == "movement_direction" or i == "movement_state" or i == "is_facing_right":
						continue
					node.set(i, node_data.get(i))
					
				if node.has_method("restore"):
					node.call("restore", node_data)

				if node.has_method("spawn_restore"):
					node.call("spawn_restore")
#
			#print(node, node_data)
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", line, " at line ", json.get_error_line())

func _on_save_button_pressed() -> void:
	if save_game_mode == SaveGameMode.NONE:
		return
	save(line_edit.text)
	animation_player.play("hide_save")
	save_game_mode = SaveGameMode.NONE
	line_edit.text = ""
	save_button.disabled = true
	GameManager.unpause()
	await get_tree().create_timer(0.5).timeout
	#TextParser.send_message("Game saved", 1.0)

func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text == "":
		save_button.disabled = true
	else:
		save_button.disabled = false

func _on_line_edit_text_submitted(_new_text: String) -> void:
	if save_game_mode == SaveGameMode.NONE:
		return
	_on_save_button_pressed()
	
func _on_cancel_button_pressed() -> void:
	if save_game_mode == SaveGameMode.NONE:
		return
	animation_player.play("hide_save")
	save_game_mode = SaveGameMode.NONE
	GameManager.unpause()
	
func _on_cancel_button_2_pressed() -> void:
	if save_game_mode == SaveGameMode.NONE:
		return
	animation_player.play("hide_restore")
	save_game_mode = SaveGameMode.NONE
	GameManager.unpause()

func _on_restore_game_pressed(description):
	if save_game_mode == SaveGameMode.NONE:
		return
	var index = _find_save_game_index(description)
	loaded_restore_index = index
	restore(index)
