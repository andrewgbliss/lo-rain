class_name Inventory extends Resource

var item_ids: Array[String]

signal inventory_change

func get_size():
	return item_ids.size()
	
func add(item_id: String):
	item_ids.append(item_id)
	inventory_change.emit()
	
func remove(item_id: String):
	item_ids.erase(item_id)
	inventory_change.emit()
	
func in_inventory(item_id: String):
	return item_ids.has(item_id)
	
func save():
	var save_dict = {
		"item_ids": item_ids
	}
	return save_dict

func restore(data):
	if data.has("item_ids"):
		for item_id in data["item_ids"]:
			item_ids.append(item_id)

func reset():
	item_ids = []
