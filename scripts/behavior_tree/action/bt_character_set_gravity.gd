class_name BTCharacterSetGravity extends BTNode

@export var has_gravity: bool = true

func process(_delta: float) -> Status:
	agent.has_gravity = has_gravity
	return Status.SUCCESS
