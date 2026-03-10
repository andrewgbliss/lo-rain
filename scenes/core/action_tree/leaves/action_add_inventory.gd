class_name ActionAddInventory extends ActionLeaf

@export var item: Item

func run() -> void:
	GameStateStore.inventory.add(item.id)
	next()
