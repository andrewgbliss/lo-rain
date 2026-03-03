class_name ActionSceneGoto extends ActionLeaf

@export var scene_path: String
@export var prev_door_id: String
@export var current_door_id: String
@export var movement_direction: CharacterController.MovementDirection

func run() -> void:
	GameStateStore.prev_door_id = prev_door_id
	GameStateStore.current_door_id = current_door_id
	GameStateStore.movement_direction = movement_direction
	SceneManager.goto_scene(scene_path)
	next()