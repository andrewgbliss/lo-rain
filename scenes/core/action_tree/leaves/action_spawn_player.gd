class_name ActionSpawnPlayer extends ActionLeaf

@export var room: Room
@export var default_spawn_position: Node2D

func run() -> void:
	var pos: Vector2 = get_player_spawn_position_vector()
	var entity = SpawnManager.spawn("player", pos, room)
	if entity != null:
		ItemManager.player = entity
	if entity is CharacterController:
		if not GameStateStore.current_door_id.is_empty():
			entity.movement_direction = GameStateStore.movement_direction
			entity.set_idle(entity.get_movement_direction_by_int(GameStateStore.movement_direction))
			GameStateStore.current_door_id = ""
			GameStateStore.prev_door_id = ""
	next()

func get_player_spawn_position_vector() -> Vector2:
	var door_node := get_player_spawn_position()
	if not GameStateStore.current_door_id.is_empty():
		return door_node.global_position if door_node != null else Vector2.ZERO
	if default_spawn_position is Node2D:
		return default_spawn_position.global_position
	return door_node.global_position if door_node != null else Vector2.ZERO

func get_player_spawn_position() -> Node2D:
	var door: RoomDoor = room.current_room_door if (room.current_room_door != null and room.current_room_door.spawn_position != null) else null
	if door == null:
		door = get_default_spawn_door()
	if door == null or door.spawn_position == null:
		return null
	return door.spawn_position as Node2D

func get_default_spawn_door() -> RoomDoor:
	if room.room_doors.is_empty():
		return null
	var sorted: Array[RoomDoor] = room.room_doors.duplicate()
	sorted.sort_custom(func(a: RoomDoor, b: RoomDoor) -> bool:
		return a.door_id < b.door_id
	)
	return sorted[0]
