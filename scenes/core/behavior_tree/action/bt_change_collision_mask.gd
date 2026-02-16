class_name BTChangeCollisionMask extends BTNode

@export var collision_mask: int = 0

func process(_delta: float) -> Status:
	if agent is CharacterController:
		agent.collision_mask = collision_mask
		return Status.SUCCESS
	return Status.FAILURE
