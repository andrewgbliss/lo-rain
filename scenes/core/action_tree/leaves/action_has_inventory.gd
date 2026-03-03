class_name ActionHasInventory extends ActionLeaf

@export var item: Item
@export var action_leaf_true: ActionLeaf
@export var action_leaf_false: ActionLeaf

func run() -> void:
	var player = SpawnManager.get_spawned_entity("player")
	if player != null and player is CharacterController:
		if player.inventory.in_inventory(item.id):
			action_leaf_true.run()
		else:
			action_leaf_false.run()
