class_name Room extends Node2D

## Loads room JSON data and runs command sequences (init, deaths, hotspots, named sections).
## Unknown commands are sent as dialogue to DialogUI.

var room_doors: Array[RoomDoor] = []
var prev_room_door: RoomDoor = null
var current_room_door: RoomDoor = null

var player

@export var room_name: String = ""

## Entity name (e.g. "car") -> Node2D used as spawn position for spawn_entity(...). Player uses room doors instead.
@export var spawn_positions: Dictionary[String, Node2D] = {}

@export var phantom_camera: PhantomCamera2D
@export var camera: Camera2D

var _data: Dictionary = {}
var _current_hotspot: Hotspot = null
## Entity name (e.g. "car", "player") -> spawned Node (from spawn_entity). Used by movement_state and other entity commands.
var _spawned_entities: Dictionary = {}

func _ready() -> void:
	room_doors = []
	_find_room_doors(self)
	TextParser.command_processed.connect(_on_command_processed)
	call_deferred("_after_ready")

func _after_ready() -> void:
	if not room_name.is_empty():
		load_room(room_name)
	_apply_door_spawn()
	_connect_hotspot_action_signals()
	_connect_hotspot_death_signals()
	run_init()

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if Input.is_action_just_pressed("pause"):
			if not GameManager.is_paused:
				GameManager.pause()
				UiManager.game_menus.push("MenuTopBar", false)
			else:
				GameManager.unpause()
				UiManager.game_menus.pop()

# ------------------------------------------------------------------------------
# Room doors
# ------------------------------------------------------------------------------

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

## Room door with the lowest door_id (string comparison), used as default spawn position.
func get_default_spawn_door() -> RoomDoor:
	if room_doors.is_empty():
		return null
	var sorted: Array[RoomDoor] = room_doors.duplicate()
	sorted.sort_custom(func(a: RoomDoor, b: RoomDoor) -> bool:
		return a.door_id < b.door_id
	)
	return sorted[0]

## Node2D to use as spawn position for the player from room doors (current_room_door when entering via door, else lowest door id). Returns null if no door.
func get_player_spawn_position() -> Node2D:
	var door: RoomDoor = current_room_door if (current_room_door != null and current_room_door.spawn_position != null) else null
	if door == null:
		door = get_default_spawn_door()
	if door == null or door.spawn_position == null:
		return null
	return door.spawn_position as Node2D

## Player spawn: entered via door → room door spawn; door blank → spawn_positions["player"] else room door else ZERO.
func get_player_spawn_position_vector() -> Vector2:
	var door_node := get_player_spawn_position()
	if not GameStateStore.current_door_id.is_empty():
		return door_node.global_position if door_node != null else Vector2.ZERO
	if spawn_positions.get("player") is Node2D:
		return (spawn_positions["player"] as Node2D).global_position
	return door_node.global_position if door_node != null else Vector2.ZERO

## If GameStateStore has current_door_id and prev_door_id (we entered via a door), set current_room_door so player spawns at that door.
func _apply_door_spawn() -> void:
	if GameStateStore.current_door_id.is_empty() or GameStateStore.prev_door_id.is_empty():
		return
	var door := get_room_door_by_id(GameStateStore.current_door_id)
	if door == null:
		return
	current_room_door = door
	prev_room_door = get_room_door_by_id(GameStateStore.prev_door_id)

# ------------------------------------------------------------------------------
# Action Trigger signals
# ------------------------------------------------------------------------------

func _connect_hotspot_action_signals() -> void:
	for hotspot in get_all_hotspots():
		for child in hotspot.get_children():
			if child is HotspotActionTrigger:
				var trigger := child as HotspotActionTrigger
				if trigger.action_run.is_connected(_on_hotspot_action_run):
					continue
				trigger.action_run.connect(_on_hotspot_action_run)

func _on_hotspot_action_run(action_id: String) -> void:
	if action_id.is_empty():
		return
	_run_actions(action_id)

# ------------------------------------------------------------------------------
# Death Trigger signals
# ------------------------------------------------------------------------------

func _connect_hotspot_death_signals() -> void:
	for hotspot in get_all_hotspots():
		for child in hotspot.get_children():
			if child is HotspotDeathTrigger:
				var trigger := child as HotspotDeathTrigger
				if trigger.death_action_run.is_connected(_on_hotspot_death_action_run):
					continue
				trigger.death_action_run.connect(_on_hotspot_death_action_run)

func _on_hotspot_death_action_run(death_action_id: String) -> void:
	if death_action_id.is_empty():
		return
	run_death(death_action_id)

# ------------------------------------------------------------------------------
# Loading
# ------------------------------------------------------------------------------

func load_room(name_or_id: String) -> bool:
	_data = GameStateStore.get_room(name_or_id)
	return _data.size() > 0

# ------------------------------------------------------------------------------
# Lookups
# ------------------------------------------------------------------------------

func get_init() -> Array:
	return _get_list("init")


func get_deaths() -> Dictionary:
	if _data.has("deaths"):
		var v = _data.deaths
		if v is Dictionary:
			return v
	return {}


func get_death(id: String) -> Array:
	var deaths: Dictionary = get_deaths()
	if deaths.has(id):
		var v = deaths[id]
		if v is Array:
			return v
		if v is String:
			return [v]
	return []


func get_hotspot(id: String) -> Dictionary:
	if not _data.has("hotspots"):
		return {}
	var hotspots = _data.hotspots
	if hotspots is not Dictionary:
		return {}
	# Exact key
	if hotspots.has(id):
		var h = hotspots[id]
		return h if h is Dictionary else {}
	# Compound key like "road|street"
	for key in hotspots.keys():
		if id in key or key in id:
			var h = hotspots[key]
			return h if h is Dictionary else {}
	return {}

func get_command(section_name: String) -> Array:
	return _get_list(section_name)

## Returns the commands array for an action by name from the room's actions dict.
func get_action_commands(action_name: String) -> Array:
	if not _data.has("actions") or _data.actions is not Dictionary:
		return []
	if _data.actions.has(action_name):
		var cmd = _data.actions[action_name]
		return cmd if cmd is Array else []
	return []

func _get_list(key: String) -> Array:
	if not _data.has(key):
		return []
	var v = _data[key]
	if v is Array:
		return v.duplicate()
	if v is String:
		return [v]
	return []

# ------------------------------------------------------------------------------
# Run
# ------------------------------------------------------------------------------

## Run a list of commands. Each item is either a builtin (quest_start(...), wait(...), action(...)) or a string to show in DialogUI.
## Use await run(...) if the sequence contains wait().
func run(commands: Array) -> void:
	for item in commands:
		var s: String = str(item).strip_edges()
		if s.is_empty():
			continue
		await _run_one(s)


## Runs init: each init entry is an action name; we look up that action's commands and run them in order.
func run_init() -> void:
	for action_name in get_init():
		var name_str: String = str(action_name).strip_edges()
		if name_str.is_empty():
			continue
		var commands: Array = get_action_commands(name_str)
		await run(commands)

func run_command(section_name: String) -> void:
	await run(get_command(section_name))

func run_death(id: String) -> void:
	run(get_death(id))

func _run_one(raw: String) -> void:
	var paren := raw.find("(")
	if paren > 0 and raw.ends_with(")"):
		var prefix: String = raw.substr(0, paren)
		var args_str: String = raw.substr(paren + 1, raw.length() - paren - 2)
		var args: PackedStringArray = []
		for part in args_str.split(","):
			args.append(part.strip_edges())
		if await _run_builtin(prefix, args):
			return
	DialogUi.dialog_text.send_message(raw)
	await DialogUi.dialog_text.is_finished

func _run_builtin(prefix: String, args: PackedStringArray) -> bool:
	match prefix:
		"quest_start":
			if args.size() >= 1:
				_call_quest_start(args[0])
			return true
		"quest_complete":
			if args.size() >= 1:
				_call_quest_complete(args[0])
			return true
		"quest_complete_checkpoint":
			if args.size() >= 2:
				_call_quest_complete_checkpoint(args[0], args[1])
			return true
		"quest_change":
			if args.size() >= 1:
				_call_quest_change(args[0])
			return true
		"quest_status":
			if args.size() >= 2:
				_call_quest_status(args[0], args[1])
			return true
		"wait":
			if args.size() >= 1:
				var sec: float = float(args[0])
				await get_tree().create_timer(sec).timeout
			return true
		"action":
			if args.size() >= 1:
				_run_action(args[0])
			return true
		"run_actions":
			if args.size() >= 1:
				await _run_actions(args[0])
			return true
		"command_prompt":
			if args.size() >= 1:
				_run_command_prompt(args[0].to_lower() == "true")
			return true
		"animation_state":
			if args.size() >= 2:
				_call_animation_state(args)
			return true
		"add_inventory":
			if args.size() >= 1:
				_call_add_inventory(args[0])
			return true
		"spawn_entity":
			if args.size() >= 1:
				if args[0] == "player":
					_call_spawn_player()
				else:
					_call_spawn_entity(args[0])
			return true
		"movement_state":
			if args.size() >= 3:
				_call_movement_state(args[0], float(args[1]), float(args[2]))
			return true
		"paralyze":
			if args.size() >= 2:
				_call_paralyze(args[0], args[1].to_lower() == "true")
			return true
		"change_collision_mask":
			if args.size() >= 2:
				_call_change_collision_mask(args[0], int(args[1]))
			return true
		"change_gravity":
			if args.size() >= 2:
				_call_change_gravity(args[0], args[1].to_lower() == "true")
			return true
		"set_idle":
			if args.size() >= 1:
				_call_set_idle(args[0])
			return true
		"set_z_index":
			if args.size() >= 2:
				_call_set_z_index(args[0], int(args[1]))
			return true
		"camera_focus":
			if args.size() >= 1:
				_call_camera_focus(args[0])
			return true
		"if_quest_completed":
			if args.size() >= 3:
				await _run_if_quest_completed(args[0], args[1], args[2])
			return true
	return false

func _call_quest_start(quest_id: String) -> void:
	QuestManager.start_quest(quest_id)

func _call_quest_complete(quest_id: String) -> void:
	QuestManager.complete_quest(quest_id)

func _call_quest_complete_checkpoint(quest_id: String, checkpoint_id: String) -> void:
	QuestManager.complete_checkpoint(quest_id, checkpoint_id)

func _call_quest_change(quest_id: String) -> void:
	QuestManager.start_quest(quest_id)

func _call_quest_status(quest_id: String, status_name: String) -> void:
	QuestManager.update_quest_status(quest_id, QuestManager.get_quest_status_by_name(status_name))

func _run_action(action_name: String) -> void:
	if action_name == "remove_inventory":
		# Extend: signal or call your inventory manager
		pass

## spawn_entity(entity_name) - spawns entity via SpawnManager at the Node2D for entity_name in spawn_positions, then calls spawn(pos) on CharacterController. Registers the entity in _spawned_entities.
func _call_spawn_entity(entity_name: String) -> void:
	if not spawn_positions.has(entity_name):
		return
	var pos_node = spawn_positions[entity_name]
	if not pos_node is Node2D:
		return
	var pos: Vector2 = (pos_node as Node2D).global_position
	var parent: Node = self
	var entity = SpawnManager.spawn(entity_name, pos, parent)
	if entity != null:
		_spawned_entities[entity_name] = entity
	if entity is CharacterController:
		entity.spawn(pos)

## Spawns the player at spawn_positions["player"] if set, else room door, else Vector2.ZERO. Restores facing and clears door ids when entering via door.
func _call_spawn_player() -> void:
	var pos: Vector2 = get_player_spawn_position_vector()
	var parent: Node = self
	var entity = SpawnManager.spawn("player", pos, parent)
	if entity != null:
		_spawned_entities["player"] = entity
	if entity is CharacterController:
		entity.spawn(pos)
		if not GameStateStore.current_door_id.is_empty():
			entity.movement_direction = GameStateStore.movement_direction
			entity.set_idle(entity.get_movement_direction_by_int(GameStateStore.movement_direction))
			GameStateStore.current_door_id = ""
			GameStateStore.prev_door_id = ""

## movement_state(entity_name, velocity_x, velocity_y) - looks up entity by name and, if it's a CharacterController, calls change_movement_state with direction derived from velocity.
func _call_movement_state(entity_name: String, velocity_x: float, velocity_y: float) -> void:
	if not _spawned_entities.has(entity_name):
		return
	var agent = _spawned_entities[entity_name]
	if agent is CharacterController:
		var move_dir := _velocity_to_movement_direction(velocity_x, velocity_y)
		agent.change_movement_state(move_dir, velocity_x, velocity_y)

## paralyze(entity_name, value) - looks up entity by name and, if it's a CharacterController, sets paralyzed.
func _call_paralyze(entity_name: String, value: bool) -> void:
	if not _spawned_entities.has(entity_name):
		return
	var agent = _spawned_entities[entity_name]
	if agent is CharacterController:
		agent.paralyzed = value

## change_collision_mask(entity_name, mask) - looks up entity by name; if CharacterController, sets collision_mask.
func _call_change_collision_mask(entity_name: String, collision_mask: int) -> void:
	if not _spawned_entities.has(entity_name):
		return
	var agent = _spawned_entities[entity_name]
	if agent is CharacterController:
		agent.collision_mask = collision_mask

## change_gravity(entity_name, value) - looks up entity by name; if CharacterController, sets has_gravity.
func _call_change_gravity(entity_name: String, has_gravity: bool) -> void:
	if not _spawned_entities.has(entity_name):
		return
	var agent = _spawned_entities[entity_name]
	if agent is CharacterController:
		agent.has_gravity = has_gravity

## set_idle(entity_name) - looks up entity by name; if CharacterController, calls set_idle().
func _call_set_idle(entity_name: String) -> void:
	if not _spawned_entities.has(entity_name):
		return
	var agent = _spawned_entities[entity_name]
	if agent is CharacterController:
		agent.set_idle()

## set_z_index(entity_name, z_index) - looks up entity by name; if Node2D, sets z_index.
func _call_set_z_index(entity_name: String, new_z_index: int) -> void:
	if not _spawned_entities.has(entity_name):
		return
	var agent = _spawned_entities[entity_name]
	if agent is Node2D:
		agent.z_index = new_z_index

## camera_focus(entity_name) - looks up entity by name and assigns it as the phantom camera's follow_target.
func _call_camera_focus(entity_name: String) -> void:
	if not _spawned_entities.has(entity_name):
		return
	var entity = _spawned_entities[entity_name]
	if phantom_camera:
		if entity is Node2D:
			phantom_camera.follow_mode = PhantomCamera2D.FollowMode.FRAMED
			phantom_camera.follow_target = entity as Node2D
			phantom_camera.follow_damping = false
			phantom_camera.set_priority(20)
	if camera:
		camera.enabled = true
		camera.make_current()
	if phantom_camera:
		await get_tree().create_timer(0.1).timeout
		phantom_camera.follow_damping = true
		phantom_camera.dead_zone_width = 0.25
		phantom_camera.dead_zone_height = 0.25


func _velocity_to_movement_direction(x: float, y: float) -> CharacterController.MovementDirection:
	if x < 0 and y < 0:
		return CharacterController.MovementDirection.UpLeft
	if x > 0 and y < 0:
		return CharacterController.MovementDirection.UpRight
	if x < 0 and y > 0:
		return CharacterController.MovementDirection.DownLeft
	if x > 0 and y > 0:
		return CharacterController.MovementDirection.DownRight
	if x < 0:
		return CharacterController.MovementDirection.Left
	if x > 0:
		return CharacterController.MovementDirection.Right
	if y < 0:
		return CharacterController.MovementDirection.Up
	if y > 0:
		return CharacterController.MovementDirection.Down
	return CharacterController.MovementDirection.None

## add_inventory(item_id) - adds item to the character in range of the current hotspot (CharacterController uses global InventoryManager).
func _call_add_inventory(item_id: String) -> void:
	var body = _get_inventory_character()
	if body is CharacterController:
		body.inventory.add(item_id)
		if _current_hotspot == null:
			return
		_current_hotspot.set_animation_state("taken", "completed")
	# else: no in-range character with inventory; could show CantDoAction

## Returns the in_range_body from the current hotspot if it has one (CharacterController with inventory).
func _get_inventory_character() -> Node:
	if _current_hotspot == null:
		return null
	return _current_hotspot.in_range_body

func _run_actions(action_name: String) -> void:
	var commands: Array = get_action_commands(action_name)
	if not commands.is_empty():
		await run(commands)

## if_quest_completed(quest_id, action_if_completed, action_if_not_completed) - runs the 2nd arg action when quest is completed, else the 3rd.
func _run_if_quest_completed(quest_id: String, action_if_completed: String, action_if_not_completed: String) -> void:
	if QuestManager.has_completed_quest(quest_id):
		await _run_actions(action_if_completed)
	else:
		await _run_actions(action_if_not_completed)

## Finds the hotspot by id (from TextParser.object) and action (from TextParser.verb),
## then runs that action's commands. Returns true if a hotspot action was found and run.
func _run_hotspot() -> bool:
	if not _data.has("hotspots") or _data.hotspots is not Dictionary:
		return false
	var obj: String = TextParser.object
	if obj.is_empty():
		return false
	var keys = _data.hotspots.keys()
	var closest_key = get_closest_key(keys, obj)
	if closest_key == null:
		return false
	var hotspot_dict = _data.hotspots[closest_key]
	if hotspot_dict is not Dictionary:
		return false
	var verb: String = TextParser.verb
	if verb.is_empty():
		return false
	var commands_dict = hotspot_dict.get("commands", {})
	if commands_dict is not Dictionary:
		return false
	var commands: Array = []
	var action_key = verb if commands_dict.has(verb) else verb.replace("_", " ")
	if not commands_dict.has(action_key):
		return false
	var val = commands_dict[action_key]
	if val is Array:
		commands = val.duplicate()
	elif val is String:
		commands = get_action_commands(val)
	elif val is Dictionary:
		commands = _resolve_conditional_commands(val, closest_key)
	if commands.is_empty():
		return false
	await run(commands)
	return true

## Resolves a conditional command object to an array of commands.
## Object may have has_completed_animation_state (state_name) or has_inventory (item_id), and "yes"/"no" arrays.
## Returns the "yes" array when the condition is true, else "no". If not a valid conditional, returns [].
func _resolve_conditional_commands(cond: Dictionary, hotspot_object_name: String) -> Array:
	if not cond.has("yes") or not cond.has("no"):
		return []
	var yes_arr = cond["yes"]
	var no_arr = cond["no"]
	if yes_arr is not Array or no_arr is not Array:
		return []
	var condition_met := false
	if cond.has("has_completed_animation_state"):
		var state_name: String = str(cond["has_completed_animation_state"]).strip_edges()
		var scene_hotspots = find_hotspots_by_object_name(hotspot_object_name)
		if not scene_hotspots.is_empty():
			var hotspot_node: Hotspot = scene_hotspots[0]
			if hotspot_node.animation_states != null and hotspot_node.animation_states.has(state_name):
				condition_met = hotspot_node.animation_states[state_name] == Hotspot.AnimationState.Completed
	if cond.has("has_inventory"):
		var item_id: String = str(cond["has_inventory"]).strip_edges()
		var player_node = get_tree().get_first_node_in_group("player")
		if player_node is CharacterController and (player_node as CharacterController).inventory != null:
			condition_met = (player_node as CharacterController).inventory.in_inventory(item_id)
	var arr: Array = yes_arr if condition_met else no_arr
	return arr.duplicate()

func _hotspot_exists_in_data(object: String, verb: String) -> bool:
	if object.is_empty() or verb.is_empty():
		return false
	var h = get_hotspot(object)
	if h.is_empty() or not h.has("commands") or h.commands is not Dictionary:
		return false
	var action_key = verb if h.commands.has(verb) else verb.replace("_", " ")
	return h.commands.has(action_key)

func _run_command_prompt(active: bool) -> void:
	DialogUi.command_prompt.active = active

## animation_state(state_name, value) - uses TextParser.object for hotspot
## animation_state(object_name, state_name, value) - explicit hotspot
func _call_animation_state(args: PackedStringArray) -> void:
	var object_name: String
	var state_name: String
	var value: String
	if args.size() >= 3:
		object_name = args[0]
		state_name = args[1]
		value = args[2].to_lower()
	else:
		object_name = TextParser.object
		state_name = args[0]
		value = args[1].to_lower()
	var hotspots := find_hotspots_by_object_name(object_name)
	for hotspot in hotspots:
		hotspot.set_animation_state(state_name, value)

func _on_command_processed(did_process: bool) -> void:
	if not did_process:
		DialogUi.dialog_text.send_message(TextParser.DontUnderstand)
		await DialogUi.dialog_text.is_finished
		return

	if TextParser.verb == "debug":
		DialogUi.dialog_text.send_message(TextParser.ReallyLongText)
		await DialogUi.dialog_text.is_finished
		return

	if TextParser.verb == "quit":
		GameManager.quit()
		return

	if TextParser.verb == "look":
		if TextParser.object == "":
			TextParser.object = "room"
			if await _run_hotspot():
				return

	var hotspot_exists = _hotspot_exists_in_data(TextParser.object, TextParser.verb)

	# Check if this object+verb exists in room data
	if hotspot_exists:
		var scene_hotspots = find_hotspots_by_object_name(TextParser.object)

		if scene_hotspots.is_empty():
			DialogUi.dialog_text.send_message(TextParser.HotspotNotFound)
			await DialogUi.dialog_text.is_finished
			return

		if scene_hotspots.size() > 1:
			DialogUi.dialog_text.send_message(TextParser.MultipleHotspots)
			await DialogUi.dialog_text.is_finished
			return

		var hotspot: Hotspot = scene_hotspots[0]
		if scene_hotspots.size() == 1 and hotspot.animation_states != null and hotspot.animation_states.get("taken") == Hotspot.AnimationState.Completed:
			DialogUi.dialog_text.send_message(TextParser.DontUnderstand)
			await DialogUi.dialog_text.is_finished
			return

		if hotspot.require_in_range and not hotspot.in_range:
			DialogUi.dialog_text.send_message(TextParser.NotCloseEnough)
			await DialogUi.dialog_text.is_finished
			return
		_current_hotspot = hotspot
		if await _run_hotspot():
			_current_hotspot = null
			return
		_current_hotspot = null

	DialogUi.dialog_text.send_message(TextParser.DontUnderstand)
	await DialogUi.dialog_text.is_finished
	return

func find_hotspots() -> Array[Hotspot]:
	var all_hotspots = get_all_hotspots()
	var found_hotspots: Array[Hotspot] = []
	for hotspot in all_hotspots:
		if hotspot.is_visible_in_tree() and hotspot.object_name:
			var object_parts = TextParser.object.split(" ", false)
			for part in object_parts:
				if part in hotspot.object_name:
					found_hotspots.append(hotspot)
					break
	return found_hotspots

## Returns scene hotspots whose object_name matches the given object (exact or closest key).
func find_hotspots_by_object_name(object: String) -> Array[Hotspot]:
	if object.is_empty():
		return []
	var all_hotspots = get_all_hotspots()
	var visible_hotspots: Array[Hotspot] = []
	for h in all_hotspots:
		if h.is_visible_in_tree() and not h.object_name.is_empty():
			visible_hotspots.append(h)
	if visible_hotspots.is_empty():
		return []
	var names: Array[String] = []
	for h in visible_hotspots:
		if h.object_name not in names:
			names.append(h.object_name)
	var closest = get_closest_key(names, object)
	if closest == null:
		return []
	var matched: Array[Hotspot] = []
	for h in visible_hotspots:
		if h.object_name == closest:
			matched.append(h)
	return matched

func get_all_hotspots() -> Array[Hotspot]:
	var hotspots: Array[Hotspot] = []
	_find_hotspots(get_tree().root, hotspots)
	return hotspots

func _find_rooms(node: Node, result: Array) -> void:
	if node is Room:
		result.append(node)

	for child in node.get_children():
		_find_rooms(child, result)

func _find_hotspots(node: Node, result: Array) -> void:
	if node is Hotspot:
		result.append(node)

	for child in node.get_children():
		_find_hotspots(child, result)

func get_current_scene() -> String:
	return get_tree().current_scene.get_name()

func get_closest_key(arr, s) -> Variant:
	for i in arr:
		if s in i:
			return i
	return null
