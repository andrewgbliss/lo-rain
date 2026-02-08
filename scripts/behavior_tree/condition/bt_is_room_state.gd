class_name BTIsRoomState extends BTNode

@export var room: Room
@export var state_key: String
@export var expected_value: bool

func process(_delta: float) -> Status:
	if state_key.is_empty():
		return Status.FAILURE
	
	if not room or not room is Room:
		return Status.FAILURE
	
	if not room.room_state.has(state_key):
		return Status.FAILURE
	
	if room.room_state[state_key] == expected_value:
		return Status.SUCCESS
	else:
		return Status.FAILURE
