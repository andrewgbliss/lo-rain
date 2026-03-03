class_name ActionSpawnEntity extends ActionLeaf

@export var room: Room
@export var spawn_position: Node2D
@export var entity_name: String

func run() -> void:
	var pos: Vector2 = spawn_position.global_position
	SpawnManager.spawn(entity_name, pos, room)
	next()
