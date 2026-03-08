class_name ActionRemoveEntity extends ActionLeaf

@export var entity_name: String

func run() -> void:
	SpawnManager.remove_entity(entity_name)
	next()
