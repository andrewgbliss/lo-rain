class_name BTChangeMovementState extends BTNode

@export var movement_direction: CharacterController.MovementDirection
@export var velocity: Vector2

func process(_delta: float) -> Status:
	if agent is CharacterController:
		agent.change_movement_state(movement_direction, velocity.x, velocity.y)
		return Status.SUCCESS
	return Status.FAILURE
