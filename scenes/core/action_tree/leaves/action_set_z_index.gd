class_name ActionSetZIndex extends ActionLeaf

@export var entity_name: String
@export var z_index: int

func run() -> void:
	var entity = SpawnManager.get_spawned_entity(entity_name)
	if entity != null and entity is Node2D:
		entity.z_index = z_index
	next()