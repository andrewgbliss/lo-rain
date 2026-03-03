class_name Hotspot extends Node2D

@export var id: String
@export var commands: Dictionary[String, ActionTree]
@export var disabled: bool = false

func _ready():
	hide()
	call_deferred("_after_ready")

func get_room_name() -> String:
	var root: Node = get_tree().get_current_scene()
	if root is Room:
		return root.room_name
	return ""

func _after_ready():
	var data = GameStateStore.get_hotspot_data(get_room_name(), id)
	restore(data)

func enable(enabled: bool) -> void:
	disabled = not enabled
	if enabled:
		show()
	else:
		hide()
	GameStateStore.set_hotspot_data(get_room_name(), id, save())

func save() -> Dictionary:
	var data = GameStateStore.get_hotspot_data(get_room_name(), id)
	data["disabled"] = disabled
	return data

func restore(data: Dictionary) -> void:
	if data == null:
		return
	disabled = data.get("disabled", disabled)
	if not disabled:
		show()
