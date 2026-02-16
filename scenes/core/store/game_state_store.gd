extends Node

const ROOMS_DIR = "res://resources/rooms/"

var _rooms: Dictionary = {}
var _hotspot_data: Dictionary = {}
var _is_loaded: bool = false

var prev_door_id: String = ""
var current_door_id: String = ""
var movement_direction: int = 0

signal has_loaded

func _ensure_loaded() -> void:
	if _is_loaded:
		return
	_is_loaded = true

	var files = FilesUtil.find_files(ROOMS_DIR, "json")
	for file_info in files:
		var file_data = FilesUtil.restore(file_info.full_path)
		if file_data != null and file_data is Dictionary:
			var file_key = file_info.filename.get_basename()
			_rooms[file_key] = file_data
			if file_data.has("id"):
				_rooms[file_data["id"]] = file_data
		else:
			push_warning("GameStateStore: Failed to load room: %s" % file_info.full_path)

	has_loaded.emit()


## Returns the room JSON dictionary for the given id.
## Supports lookup by room id (e.g. "long-road") or filename (e.g. "long_road").
## Returns empty dictionary if room not found.
func get_room(id: String) -> Dictionary:
	_ensure_loaded()
	if _rooms.has(id):
		return _rooms[id]
	push_error("Error: A room data is missing!", id)
	return {}


## Returns saved hotspot data for the given id. Returns empty dictionary if none.
func get_hotspot_data(id: String) -> Dictionary:
	if _hotspot_data.has(id):
		return _hotspot_data[id]
	return {}


## Stores hotspot data for the given id (e.g. hotspot object_name or node path).
func set_hotspot_data(id: String, data: Dictionary) -> void:
	_hotspot_data[id] = data
