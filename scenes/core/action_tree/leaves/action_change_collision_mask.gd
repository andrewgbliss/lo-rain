class_name ActionChangeCollisionMask extends ActionLeaf

@export var entity_name: String
@export var collision_mask: int

func run() -> void:
	var entity = SpawnManager.get_spawned_entity(entity_name)
	if entity != null and entity is CharacterController:
		entity.collision_mask = collision_mask
	next()
