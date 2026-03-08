class_name ActionCharacterSetScaleFactor extends ActionLeaf

@export var entity_name: String
@export var use_scale_factor: bool = false
@export var scale_factor: float
@export var scale_factor_min: float = 0.5
@export var scale_factor_max: float = 2.0

func run() -> void:
	var entity = SpawnManager.get_spawned_entity(entity_name)
	if entity != null and entity is CharacterController:
		entity.use_scale_factor = use_scale_factor
		entity.scale_factor = scale_factor
		entity.scale_factor_min = scale_factor_min
		entity.scale_factor_max = scale_factor_max
	next()