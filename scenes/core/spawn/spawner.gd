class_name Spawner extends Node2D

@export var entity_name: String
@export var spawn_on_ready: bool = false
@export var spawn_container: Node2D
@export var wait_for_seconds: float = 1
@export var repeat: bool = false
@export var only_if_none: bool = true
@export var only_group: String = "enemy"

func _ready():
	if entity_name and spawn_on_ready:
		_spawn_entity()

func _spawn_entity():
	await get_tree().create_timer(wait_for_seconds).timeout
	
	var nodes = get_tree().get_nodes_in_group(only_group)
	
	if (nodes.size() == 0 and only_if_none) or not only_if_none:
		var entity = SpawnManager.spawn(entity_name, global_position, spawn_container)
		if entity is CharacterController:
			entity.spawn()
	if repeat:
		_spawn_entity()
