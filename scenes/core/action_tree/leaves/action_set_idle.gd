class_name ActionSetIdle extends ActionLeaf

@export var entity_name: String

func run() -> void:
	var entity = SpawnManager.get_spawned_entity(entity_name)
	if entity != null and entity is CharacterController:
		entity.set_idle()
	next()