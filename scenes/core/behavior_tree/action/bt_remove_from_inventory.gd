class_name BTRemoveFromInventory extends BTNode

@export var item: Item

func process(_delta: float) -> Status:
	if not item:
		return Status.FAILURE
	
	if not InventoryManager.inventory.in_inventory(item.id):
		return Status.SUCCESS
	
	InventoryManager.inventory.remove(item.id)
		
	return Status.SUCCESS
