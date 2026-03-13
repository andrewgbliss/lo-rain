class_name RoomDoor extends Area2D

@export var door_id: String
@export var goto_door_id: String
@export var scene_path: String
@export var spawn_position: SpawnPosition
@export var spawn_direction: CharacterController.MovementDirection = CharacterController.MovementDirection.Right
@export var disabled: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if disabled:
		return
	if body is CharacterController:
		body.set_paralyzed(true)
		body.set_idle()
		GameStateStore.prev_door_id = door_id
		GameStateStore.current_door_id = goto_door_id
		SceneManager.goto_scene(scene_path)
