class_name BTPlayerActive extends BTNode

@export var player: BTPlayers
@export var active: bool = true

func process(_delta: float) -> Status:
	if player:
		player.is_running = active
	return Status.SUCCESS
