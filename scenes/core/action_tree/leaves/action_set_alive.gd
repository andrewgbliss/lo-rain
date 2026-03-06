class_name ActionSetAlive extends ActionLeaf

@export var entity_name: String
@export var value: bool

func run() -> void:
	var entity = SpawnManager.get_spawned_entity(entity_name)
	if entity != null and entity is CharacterController:
		entity.is_alive = value
	next()
