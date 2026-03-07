class_name ActionIsDemoMode extends ActionLeaf

@export var action_leaf_true: ActionLeaf
@export var action_leaf_false: ActionLeaf

func run() -> void:
	if GameManager.demo_mode:
		if action_leaf_true:
			action_leaf_true.run()
	elif action_leaf_false:
		action_leaf_false.run()
