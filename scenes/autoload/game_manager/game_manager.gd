extends Node

var game_data: GameData = GameData.new()

signal on_pause
signal on_unpause

func save():
	game_data.current_scene_path = get_tree().current_scene.scene_file_path
	return game_data.save()
	
func restore(data):
	game_data.restore(data)

func reset():
	game_data.reset()

func pause():
	get_tree().paused = true
	on_pause.emit()

func unpause():
	get_tree().paused = false
	on_unpause.emit()

func quit():
	get_tree().quit()
