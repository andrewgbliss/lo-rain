class_name ActionSetHotspotState extends ActionLeaf

@export var hotspot: Hotspot
@export var state: String
@export var value: bool

func run() -> void:
	GameStateStore.set_hotspot_state(hotspot.get_room_name(), hotspot.id, state, value)
	next()
