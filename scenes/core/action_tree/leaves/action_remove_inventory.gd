class_name ActionRemoveInventory extends ActionLeaf

@export var item: Item

func run() -> void:
	GameStateStore.inventory.remove(item.id)
	next()
