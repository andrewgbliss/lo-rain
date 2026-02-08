class_name BTSetRoomState extends BTNode

@export var room: Room
@export var state_key: String
@export var state_value: bool

func process(_delta: float) -> Status:
	if state_key.is_empty():
		return Status.FAILURE
	
	if not room or not room is Room:
		return Status.FAILURE
	
	room.room_state[state_key] = state_value
	return Status.SUCCESS
