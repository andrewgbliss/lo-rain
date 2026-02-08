class_name RoomDoor extends Area2D

@export var door_id: String
@export var goto_door_id: String
@export var scene_path: String
@export var spawn_position: SpawnPosition

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body is CharacterController:
		GameManager.game_data.prev_door_id = door_id
		GameManager.game_data.current_door_id = goto_door_id
		GameManager.game_data.movement_direction = body.movement_direction
		SceneManager.goto_scene(scene_path)

func spawn_player(player: CharacterController):
	if spawn_position:
		player.spawn(spawn_position.global_position)
