@tool

class_name Room extends Node2D

@export var room_name: String = ""

var room_doors: Array[RoomDoor] = []
var prev_room_door: RoomDoor = null
var current_room_door: RoomDoor = null

@export_tool_button("Add Hotspots Container", "Callable") var add_hotspots_container_action = add_hotspots_container
@export_tool_button("Add Hotspot Resolver", "Callable") var add_hotspot_resolver_action = add_hotspot_resolver
@export_tool_button("Add Default Room Hotspot", "Callable") var add_default_room_hotspot_action = add_default_room_hotspot

func add_hotspots_container():
	var hotspots_container = Node2D.new()
	hotspots_container.name = "Hotspots"
	add_child(hotspots_container)
	hotspots_container.owner = get_tree().edited_scene_root

func add_hotspot_resolver():
	var hotspots_container = get_node("Hotspots")
	if hotspots_container == null:
		return

	var hotspot_resolver = HotspotResolver.new()
	hotspot_resolver.name = "HotspotResolver"
	hotspots_container.add_child(hotspot_resolver)
	hotspot_resolver.owner = get_tree().edited_scene_root

func add_default_room_hotspot():
	var hotspots_container = get_node("Hotspots")
	if hotspots_container == null:
		return

	var room_hotspot = Hotspot.new()
	room_hotspot.name = "Room"
	room_hotspot.id = "room"
	hotspots_container.add_child(room_hotspot)
	room_hotspot.owner = get_tree().edited_scene_root

	var action_tree = ActionTree.new()
	action_tree.name = "Look"
	var action_dialog = ActionDialog.new()
	action_dialog.name = "ActionDialog"
	action_tree.add_child(action_dialog)
	room_hotspot.add_child(action_tree)
	action_tree.owner = get_tree().edited_scene_root
	action_dialog.owner = get_tree().edited_scene_root
	action_tree.root_leaf = action_dialog
	room_hotspot.commands["look"] = action_tree

	var help_action_tree = ActionTree.new()
	help_action_tree.name = "Help"
	var help_action_dialog = ActionDialog.new()
	help_action_dialog.name = "ActionDialog"
	help_action_tree.add_child(help_action_dialog)
	room_hotspot.add_child(help_action_tree)
	help_action_tree.owner = get_tree().edited_scene_root
	help_action_dialog.owner = get_tree().edited_scene_root
	help_action_tree.root_leaf = help_action_dialog
	room_hotspot.commands["help"] = help_action_tree

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	room_doors = []
	_find_room_doors(self )
	_apply_door_spawn()

func get_room_door_by_id(id: String) -> RoomDoor:
	for door in room_doors:
		if door.door_id == id:
			return door
	return null

func _find_room_doors(node: Node) -> void:
	if node is RoomDoor:
		room_doors.append(node)
	for child in node.get_children():
		_find_room_doors(child)

func _apply_door_spawn() -> void:
	if GameStateStore.current_door_id.is_empty() or GameStateStore.prev_door_id.is_empty():
		return
	var door := get_room_door_by_id(GameStateStore.current_door_id)
	if door == null:
		return
	current_room_door = door
	prev_room_door = get_room_door_by_id(GameStateStore.prev_door_id)
