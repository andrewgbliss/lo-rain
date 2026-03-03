class_name ActionHasState extends ActionLeaf

@export var state_name: String
@export var value: bool
@export var action_leaf_true: ActionLeaf
@export var action_leaf_false: ActionLeaf

func run() -> void:
	if GameStateStore.get_state(state_name) == value:
		if action_leaf_true:
			action_leaf_true.run()
	elif action_leaf_false:
		action_leaf_false.run()
