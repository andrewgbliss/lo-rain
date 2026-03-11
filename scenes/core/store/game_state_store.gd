extends Node

@export var inventory: Inventory
@export var state: Dictionary[String, bool]
@export var rooms: Dictionary = {}

var prev_door_id: String = ""
var current_door_id: String = ""
var movement_direction: int = 0
var player_hp: int = 0
var player_max_hp: int = 0
	
func get_hotspot_data(room_id: String, hotspot_id: String) -> Dictionary:
	if not rooms.has(room_id):
		return {}
	if rooms[room_id].has("hotspots") and rooms[room_id]["hotspots"].has(hotspot_id):
		return rooms[room_id]["hotspots"][hotspot_id]
	return {}
	
func get_hotspot_state(room_id: String, hotspot_id: String, key: String) -> bool:
	if not rooms.has(room_id):
		return false
	if rooms[room_id].has("hotspots") and rooms[room_id]["hotspots"].has(hotspot_id):
		return rooms[room_id]["hotspots"][hotspot_id].get(key, false)
	return false

func set_hotspot_state(room_id: String, hotspot_id: String, key: String, value: bool) -> void:
	if not rooms.has(room_id):
		rooms[room_id] = {
			"hotspots": {}
		}
	if not rooms[room_id]["hotspots"].has(hotspot_id):
		rooms[room_id]["hotspots"][hotspot_id] = {}
	rooms[room_id]["hotspots"][hotspot_id].set(key, value)
		
func set_hotspot_data(room_id: String, hotspot_id: String, data: Dictionary) -> void:
	if not rooms.has(room_id):
		rooms[room_id] = {
			"hotspots": {}
		}
	rooms[room_id]["hotspots"].set(hotspot_id, data)

func get_state(key: String) -> bool:
	return state.get(key, false)

func set_state(key: String, value: bool) -> void:
	state[key] = value

func save() -> Dictionary:
	return {
		"prev_door_id": prev_door_id,
		"current_door_id": current_door_id,
		"movement_direction": movement_direction,
		"state": state,
		"rooms": rooms,
		"player_hp": player_hp,
		"player_max_hp": player_max_hp,
		"inventory": inventory.save()
	}

func restore(data: Dictionary) -> void:
	prev_door_id = data.get("prev_door_id", "")
	current_door_id = data.get("current_door_id", "")
	movement_direction = data.get("movement_direction", 0)
	state = data.get("state", {})
	rooms = data.get("rooms", {})
	player_hp = data.get("player_hp", 0)
	player_max_hp = data.get("player_max_hp", 0)
	inventory.restore(data.get("inventory", {}))
	
func reset() -> void:
	prev_door_id = ""
	current_door_id = ""
	movement_direction = 0
	state = {}
	rooms = {}
	player_hp = 0
	player_max_hp = 0
	inventory.reset()
