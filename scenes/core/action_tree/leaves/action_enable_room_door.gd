class_name ActionEnableRoomDoor extends ActionLeaf

@export var room_door: RoomDoor
@export var enabled: bool = true

func run() -> void:
	room_door.disabled = not enabled
	next()