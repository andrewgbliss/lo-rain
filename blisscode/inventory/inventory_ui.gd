extends Node2D

@export var animation_player: AnimationPlayer
@export var inventory_container: VBoxContainer

var is_open = false

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if Input.is_action_just_pressed("ui_cancel") and is_open:
			close()

func open():
	is_open = true
	for item in InventoryManager.inventory.item_ids:
		var label = Label.new()
		label.text = item
		inventory_container.add_child(label)
	animation_player.play("open")

func close():
	is_open = false
	animation_player.play("close")
