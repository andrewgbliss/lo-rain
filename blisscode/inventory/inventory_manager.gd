extends Node2D

var inventory: Inventory = Inventory.new()

signal inventory_loaded
signal inventory_restored

func _ready() -> void:
	call_deferred("_deferred_loaded")
	
func _deferred_loaded():
	inventory_loaded.emit()

func save():
	return inventory.save()

func restore(data):
	inventory.restore(data)
	inventory_restored.emit()

func reset():
	inventory.reset()
