class_name ActionNpcRunAnimation extends ActionLeaf

@export var entity_name: String
@export var animation_name: String

func run() -> void:
	var entity = SpawnManager.get_spawned_entity(entity_name)
	if entity != null and entity is CharacterController:
		if entity.animation_player and entity.animation_player.has_animation(animation_name):
			entity.animation_player.play(animation_name)
	next()