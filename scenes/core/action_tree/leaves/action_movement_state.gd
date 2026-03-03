class_name ActionMovementState extends ActionLeaf

@export var entity_name: String
@export var velocity_x: float
@export var velocity_y: float

func _velocity_to_movement_direction(x: float, y: float) -> CharacterController.MovementDirection:
	if x < 0 and y < 0:
		return CharacterController.MovementDirection.UpLeft
	if x > 0 and y < 0:
		return CharacterController.MovementDirection.UpRight
	if x < 0 and y > 0:
		return CharacterController.MovementDirection.DownLeft
	if x > 0 and y > 0:
		return CharacterController.MovementDirection.DownRight
	if x < 0:
		return CharacterController.MovementDirection.Left
	if x > 0:
		return CharacterController.MovementDirection.Right
	if y < 0:
		return CharacterController.MovementDirection.Up
	if y > 0:
		return CharacterController.MovementDirection.Down
	return CharacterController.MovementDirection.None

func run() -> void:
	var entity = SpawnManager.get_spawned_entity(entity_name)
	if entity != null and entity is CharacterController:
		var move_dir := _velocity_to_movement_direction(velocity_x, velocity_y)
		entity.change_movement_state(move_dir, velocity_x, velocity_y)
	next()
