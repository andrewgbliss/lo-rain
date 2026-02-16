class_name BTAddToInventory extends BTNode

@export var item: Item

func process(_delta: float) -> Status:
	if not item:
		return Status.FAILURE
	
	if InventoryManager.inventory.in_inventory(item.id):
		return Status.SUCCESS
	
	InventoryManager.inventory.add(item.id)
		
	return Status.SUCCESS
