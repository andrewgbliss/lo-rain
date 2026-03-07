class_name HotspotResolver extends Node

func _ready() -> void:
	SignalBus.command_processed.connect(_on_command_processed)

## Finds a command key in commands_dict that matches the verb.
## Keys may be "verb" or "verb1|verb2|verb3" (pipe-separated alternatives).
func _find_command_key(commands_dict: Dictionary, verb: String) -> String:
	if verb.is_empty():
		return ""
	if commands_dict.has(verb):
		return verb
	var verb_spaces := verb.replace("_", " ")
	if commands_dict.has(verb_spaces):
		return verb_spaces
	for key in commands_dict.keys():
		if "|" in key:
			var aliases: PackedStringArray = key.split("|")
			for alias in aliases:
				var cleaned: String = alias.strip_edges()
				if cleaned == verb or cleaned == verb_spaces:
					return key
	return ""

## Finds the hotspot by id (from TextParser.object) and action (from TextParser.verb),
## then runs that action's ActionTree. Returns true if a hotspot action was found and run.
func _run_hotspot() -> String:
	var obj := TextParser.object.strip_edges()
	var verb := TextParser.verb.strip_edges()
	if obj.is_empty() or verb.is_empty():
		return TextParser.DontUnderstand

	var hotspot := _find_hotspot_by_id(obj)
	if hotspot == null:
		return TextParser.HotspotNotFound

	var commands_dict: Dictionary = hotspot.commands
	if commands_dict.is_empty():
		return TextParser.CantDoAction

	var action_key := _find_command_key(commands_dict, verb)
	if action_key.is_empty():
		return TextParser.CantDoAction

	var tree: ActionTree = hotspot.commands[action_key]
	if tree == null:
		return TextParser.CantDoAction

	tree.run()
	return ""

func _find_hotspot_by_id(object: String) -> Hotspot:
	if object.is_empty():
		return null

	var target := object.strip_edges().to_lower()
	var all_hotspots: Array[Hotspot] = []
	_collect_hotspots(get_tree().root, all_hotspots)

	var partial_match: Hotspot = null
	for hotspot in all_hotspots:
		if hotspot.id.is_empty():
			continue
		var variants := hotspot.id.split("|", false)
		for raw in variants:
			var id_name := raw.strip_edges().to_lower()
			if id_name == target:
				return hotspot
			if partial_match == null and target in id_name:
				partial_match = hotspot
				break

	return partial_match

func _collect_hotspots(node: Node, result: Array) -> void:
	if node is Hotspot:
		if not node.disabled:
			result.append(node)
	for child in node.get_children():
		_collect_hotspots(child, result)

func _on_command_processed(did_process: bool) -> void:
	if not did_process:
		DialogUi.dialog_text.send_message(TextParser.DontUnderstand)
		await DialogUi.dialog_text.is_finished
		return

	var verb := TextParser.verb

	if verb == "debug":
		DialogUi.dialog_text.send_message(TextParser.ReallyLongText)
		await DialogUi.dialog_text.is_finished
		return

	if verb == "quit":
		GameManager.quit()
		return

	# "look" with no object should target the room Hotspot (id = "room").
	if (verb == "look" or verb == "help") and TextParser.object == "":
		TextParser.object = "room"

	var message = _run_hotspot()
	if message.is_empty():
		return

	DialogUi.dialog_text.send_message(message)
	await DialogUi.dialog_text.is_finished
