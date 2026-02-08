extends Node

@export var initial_soundtrack: String = "Soundtrack"

var save_file_path = "user://save/"
var save_file_name = "AudioData.tres"
var audio: Dictionary[String, AudioStreamPlayer2D] = {}
var bus_idx_volume = [50, 50, 50]

func _ready():
	DirAccess.make_dir_absolute(save_file_path)
	load_audio_data()
	var default_db = convert_percent_to_db(50)
	AudioServer.set_bus_volume_db(0, default_db)
	for i in range(3):
		var db = convert_percent_to_db(bus_idx_volume[i])
		AudioServer.set_bus_volume_db(i + 1, db)
	for child in get_children():
		if child is AudioStreamPlayer2D:
			audio[child.name] = child
	if GameManager.game_data.play_initial_music and initial_soundtrack:
		play(initial_soundtrack)

func set_volume(bus_idx, volume):
	bus_idx_volume[bus_idx] = volume
	var i = bus_idx + 1
	if (volume == 0):
		AudioServer.set_bus_mute(i, true)
	else:
		if AudioServer.is_bus_mute(i):
			AudioServer.set_bus_mute(i, false)
		var db = convert_percent_to_db(volume)
		AudioServer.set_bus_volume_db(i, db)
	save_audio_data()
		
func convert_percent_to_db(percent):
	var scale = 20
	var divisor = 50
	return scale * log(percent / divisor) / log(10)

func play(node_name: String):
	audio[node_name].play()

func play_random(names):
	var random_index = randi_range(0, names.size() - 1)
	audio[names[random_index]].play()

func play_and_wait(node_name: String):
	audio[node_name].play()
	await audio[node_name].finished

func stop(node_name: String):
	audio[node_name].stop()

func save_audio_data():
	var file = FileAccess.open(save_file_path + save_file_name, FileAccess.WRITE)
	var json_string = JSON.stringify(bus_idx_volume)
	file.store_string(json_string)
	file.close()

func load_audio_data():
	if FileAccess.file_exists(save_file_path + save_file_name):
		var file = FileAccess.open(save_file_path + save_file_name, FileAccess.READ)
		var json_string = file.get_as_text()
		bus_idx_volume = JSON.parse_string(json_string)
		file.close()
