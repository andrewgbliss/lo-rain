class_name ActionSetState extends ActionLeaf

@export var state_name: String
@export var value: bool

func run() -> void:
	GameStateStore.set_state(state_name, value)
	next()