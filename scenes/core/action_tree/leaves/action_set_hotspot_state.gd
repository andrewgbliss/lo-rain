class_name ActionSetHotspotState extends ActionLeaf

@export var hotspot: Hotspot
@export var state: String
@export var value: bool

func run() -> void:
	var data = GameStateStore.get_hotspot_data(hotspot.get_room_name(), hotspot.id)
	data[state] = value
	GameStateStore.set_hotspot_data(hotspot.get_room_name(), hotspot.id, data)
	next()