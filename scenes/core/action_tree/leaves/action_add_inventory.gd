class_name ActionAddInventory extends ActionLeaf

@export var item: Item

func run() -> void:
	var player = SpawnManager.get_spawned_entity("player")
	if player != null and player is CharacterController:
		player.inventory.add(item.id)
	next()
