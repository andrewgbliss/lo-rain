class_name ActionHasHotspotState extends ActionLeaf

@export var hotspot: Hotspot
@export var state: String
@export var value: bool
@export var action_leaf_true: ActionLeaf
@export var action_leaf_false: ActionLeaf

func run() -> void:
	var state_value = GameStateStore.get_hotspot_state(hotspot.get_room_name(), hotspot.id, state)	
	if state_value == value:
		if action_leaf_true:
			action_leaf_true.run()
	elif action_leaf_false:
		action_leaf_false.run()
