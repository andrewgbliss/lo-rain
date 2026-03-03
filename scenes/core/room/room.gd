class_name Room extends Node2D

@export var room_name: String = ""

var room_doors: Array[RoomDoor] = []
var prev_room_door: RoomDoor = null
var current_room_door: RoomDoor = null

func _ready() -> void:
	room_doors = []
	_find_room_doors(self )
	_apply_door_spawn()

func get_room_door_by_id(id: String) -> RoomDoor:
	for door in room_doors:
		if door.door_id == id:
			return door
	return null

func _find_room_doors(node: Node) -> void:
	if node is RoomDoor:
		room_doors.append(node)
	for child in node.get_children():
		_find_room_doors(child)

func _apply_door_spawn() -> void:
	if GameStateStore.current_door_id.is_empty() or GameStateStore.prev_door_id.is_empty():
		return
	var door := get_room_door_by_id(GameStateStore.current_door_id)
	if door == null:
		return
	current_room_door = door
	prev_room_door = get_room_door_by_id(GameStateStore.prev_door_id)
