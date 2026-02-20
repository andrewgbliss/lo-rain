extends Node

@export var items: Dictionary[String, Item] = {}

var player

func get_item(item_id: String):
	return items[item_id]
