@tool

class_name Hotspot extends Node2D

@export var id: String
@export var commands: Dictionary[String, ActionTree]
@export var disabled: bool = false

@export_tool_button("Add Look Dialog", "Add") var add_look_dialog_action = add_look_dialog
@export_tool_button("Add Take Dialog", "Add") var add_take_dialog_action = add_take_dialog
@export_tool_button("Add Talk Dialog", "Add") var add_talk_dialog_action = add_talk_dialog
@export_tool_button("Add Use Dialog", "Add") var add_use_dialog_action = add_use_dialog
@export_tool_button("Add In Range Collision", "Add") var add_in_range_collision_action = add_in_range_collision

func add_look_dialog():
	var action_tree = ActionTree.new()
	action_tree.name = "Look"
	var action_dialog = ActionDialog.new()
	action_dialog.name = "ActionDialog"
	action_tree.add_child(action_dialog)
	add_child(action_tree)
	action_tree.owner = get_tree().edited_scene_root
	action_dialog.owner = get_tree().edited_scene_root
	action_tree.root_leaf = action_dialog
	commands["look"] = action_tree

func add_take_dialog():
	var action_tree = ActionTree.new()
	action_tree.name = "Take"
	var action_dialog = ActionDialog.new()
	action_dialog.name = "ActionDialog"
	action_tree.add_child(action_dialog)
	add_child(action_tree)
	action_tree.owner = get_tree().edited_scene_root
	action_dialog.owner = get_tree().edited_scene_root
	action_tree.root_leaf = action_dialog
	commands["take"] = action_tree

func add_talk_dialog():
	var action_tree = ActionTree.new()
	action_tree.name = "Talk"
	var action_dialog = ActionDialog.new()
	action_dialog.name = "ActionDialog"
	action_tree.add_child(action_dialog)
	add_child(action_tree)
	action_tree.owner = get_tree().edited_scene_root
	action_dialog.owner = get_tree().edited_scene_root
	action_tree.root_leaf = action_dialog
	commands["talk"] = action_tree

func add_use_dialog():
	var action_tree = ActionTree.new()
	action_tree.name = "Use"
	var action_dialog = ActionDialog.new()
	action_dialog.name = "ActionDialog"
	action_tree.add_child(action_dialog)
	add_child(action_tree)
	action_tree.owner = get_tree().edited_scene_root
	action_dialog.owner = get_tree().edited_scene_root
	action_tree.root_leaf = action_dialog
	commands["use"] = action_tree

func add_in_range_collision():
	var hotspot_in_range = HotspotInRange.new()
	hotspot_in_range.name = "HotspotInRange"
	hotspot_in_range.collision_layer = 32
	var collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	collision_shape.shape = CircleShape2D.new()
	collision_shape.shape.radius = 10
	hotspot_in_range.add_child(collision_shape)
	add_child(hotspot_in_range)

	collision_shape.owner = get_tree().edited_scene_root
	hotspot_in_range.owner = get_tree().edited_scene_root

func _ready():
	if Engine.is_editor_hint():
		return
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
