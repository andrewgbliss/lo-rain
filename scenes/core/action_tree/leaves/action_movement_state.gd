class_name ActionMovementState extends ActionLeaf

@export var entity_name: String
@export var movement_direction: CharacterController.MovementDirection
@export var velocity_x: float
@export var velocity_y: float

func run() -> void:
	var entity = SpawnManager.get_spawned_entity(entity_name)
	if entity != null and entity is CharacterController:
		entity.change_movement_state(movement_direction, velocity_x, velocity_y)
	next()
