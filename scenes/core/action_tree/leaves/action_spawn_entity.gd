class_name ActionSpawnEntity extends ActionLeaf

@export var room: Room
@export var spawn_position: Node2D
@export var entity_name: String

func run() -> void:
	var pos: Vector2 = spawn_position.global_position
	var entity = SpawnManager.spawn(entity_name, pos, room)
	if entity is CharacterController:
		if SaveGameManager.loaded_restore_index != 0:
			entity.spawn_restore()
		else:
			entity.spawn(pos)
	next()
