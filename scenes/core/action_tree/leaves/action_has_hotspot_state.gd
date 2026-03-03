class_name ActionHasHotspotState extends ActionLeaf

@export var hotspot: Hotspot
@export var state: String
@export var value: bool
@export var action_leaf_true: ActionLeaf
@export var action_leaf_false: ActionLeaf

func run() -> void:
	var data = GameStateStore.get_hotspot_data(hotspot.get_room_name(), hotspot.id)
	if data.has(state) and data[state] == value:
		action_leaf_true.run()
	else:
		action_leaf_false.run()
