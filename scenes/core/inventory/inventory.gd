class_name Inventory extends Resource

var item_ids: Array[String] = []

var inventory_path = "user://inventory.json"

func get_size():
	return item_ids.size()
	
func add(item_id: String):
	item_ids.append(item_id)
	save_to_file()

func remove(item_id: String):
	item_ids.erase(item_id)
	save_to_file()

func in_inventory(item_id: String):
	return item_ids.has(item_id)
	
func save():
	var save_dict = {
		"item_ids": item_ids
	}
	return save_dict

func save_to_file():
	var save_dict = save()
	FilesUtil.save(inventory_path, save_dict)

func restore(data: Dictionary):
	if data.has("item_ids"):
		for item_id in data["item_ids"]:
			item_ids.append(item_id)

func restore_from_file():
	var data = FilesUtil.restore(inventory_path)
	if data == null:
		return
	restore(data)

func reset():
	FilesUtil.remove_file(inventory_path)
	item_ids = ['id', 'screw_driver']
	save_to_file()
