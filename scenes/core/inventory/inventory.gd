class_name Inventory extends Resource

@export var item_ids: Array[String] = ['id', 'screw_driver']

func get_size():
	return item_ids.size()
	
func add(item_id: String):
	item_ids.append(item_id)

func remove(item_id: String):
	item_ids.erase(item_id)

func in_inventory(item_id: String):
	return item_ids.has(item_id)
	
func save():
	var save_dict = {
		"item_ids": item_ids
	}
	return save_dict

func restore(data: Dictionary):
	if data.has("item_ids"):
		for item_id in data["item_ids"]:
			item_ids.append(item_id)
	restore(data)

func reset():
	item_ids = ['id', 'screw_driver']
