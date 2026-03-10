extends Node

@export var items: Dictionary[String, Item] = {}

func get_item(item_id: String):
	return items[item_id]
