class_name BTIsInInventory extends BTNode

@export var item: Item

func process(_delta: float) -> Status:
	if InventoryManager.inventory.in_inventory(item.id):
		return Status.SUCCESS
	return Status.FAILURE
