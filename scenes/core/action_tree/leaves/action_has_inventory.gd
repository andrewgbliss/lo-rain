class_name ActionHasInventory extends ActionLeaf

@export var item: Item
@export var action_leaf_true: ActionLeaf
@export var action_leaf_false: ActionLeaf

func run() -> void:
	if GameStateStore.inventory.in_inventory(item.id):
		if action_leaf_true:
			action_leaf_true.run()
	elif action_leaf_false:
		action_leaf_false.run()
