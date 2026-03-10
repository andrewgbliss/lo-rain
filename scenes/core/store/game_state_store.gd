extends Node

@export var inventory: Inventory

var _rooms: Dictionary = {}
var _state: Dictionary = {}

var prev_door_id: String = ""
var current_door_id: String = ""
var movement_direction: int = 0
var player_hp: int = 0
var player_max_hp: int = 0

func get_hotspot_data(room_id: String, hotspot_id: String) -> Dictionary:
	if not _rooms.has(room_id):
		return {}
	var room = _rooms[room_id]
	if room.has("hotspots") and room["hotspots"].has(hotspot_id):
		return room["hotspots"][hotspot_id]
	return {}

func set_hotspot_data(room_id: String, hotspot_id: String, data: Dictionary) -> void:
	if not _rooms.has(room_id):
		_rooms[room_id] = {}
	var room = _rooms[room_id]
	if room.has("hotspots"):
		room["hotspots"][hotspot_id] = data
	else:
		room["hotspots"] = {hotspot_id: data}

func get_state(key: String) -> bool:
	return _state.get(key, false)

func set_state(key: String, value: bool) -> void:
	_state[key] = value

func save() -> Dictionary:
	return {
		"prev_door_id": prev_door_id,
		"current_door_id": current_door_id,
		"movement_direction": movement_direction,
		"state": _state,
		"rooms": _rooms,
		"player_hp": player_hp,
		"player_max_hp": player_max_hp,
		"inventory": inventory.save()
	}

func restore(data: Dictionary) -> void:
	prev_door_id = data.get("prev_door_id", "")
	current_door_id = data.get("current_door_id", "")
	movement_direction = data.get("movement_direction", 0)
	_state = data.get("state", {})
	_rooms = data.get("rooms", {})
	player_hp = data.get("player_hp", 0)
	player_max_hp = data.get("player_max_hp", 0)
	inventory.restore(data.get("inventory", {}))
	
func reset() -> void:
	prev_door_id = ""
	current_door_id = ""
	movement_direction = 0
	_state = {}
	_rooms = {}
	player_hp = 0
	player_max_hp = 0
	inventory.reset()
