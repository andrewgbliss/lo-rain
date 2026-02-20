class_name RoomDoor extends Area2D

@export var door_id: String
@export var goto_door_id: String
@export var scene_path: String
@export var spawn_position: SpawnPosition
@export var room_hotspot_data: Dictionary[String, String]

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body is CharacterController:
		GameStateStore.prev_door_id = door_id
		GameStateStore.current_door_id = goto_door_id
		GameStateStore.movement_direction = body.movement_direction
		if not room_hotspot_data.is_empty():
			for hotspot_data in room_hotspot_data.keys():
				var parts = hotspot_data.split("|")
				var room_name = parts[0]
				var hotspot_id = parts[1]
				var animation_state = parts[2]
				var value = room_hotspot_data[hotspot_data]
				if room_name and hotspot_id and animation_state and value:
					var data = GameStateStore.get_hotspot_data(room_name, hotspot_id)
					data["animation_states"][animation_state] = value
					GameStateStore.set_hotspot_data(room_name, hotspot_id, data)
		SceneManager.goto_scene(scene_path)
