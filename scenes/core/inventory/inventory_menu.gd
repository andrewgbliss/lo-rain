class_name InventoryMenu extends Menu

@export var inventory_container: GridContainer

func _ready():
	super ()
	_clear_inventory()

func _clear_inventory():
	for child in inventory_container.get_children():
		child.queue_free()

func _update_inventory(item_ids: Array[String]):
	_clear_inventory()
	for i in range(item_ids.size()):
		var item_id = item_ids[i]
		var button = _add_button(item_id)
		if i == 0:
			button.grab_focus()
	
func _add_button(item_id: String):
	var item = ItemManager.get_item(item_id)
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(16, 16)
	var texture_rect = TextureRect.new()
	texture_rect.size = Vector2(16, 16)
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP
	texture_rect.texture = item.icon_texture
	btn.add_child(texture_rect)
	btn.pressed.connect(_on_item_selected.bind(item_id))
	inventory_container.add_child(btn)
	return btn

func _on_item_selected(item_id: String):
	parent.pop_all()
	GameManager.unpause()
	await get_tree().create_timer(0.5).timeout
	# print("Item selected: ", item_id)
	var item = ItemManager.get_item(item_id)
	var message = item.description
	DialogUi.dialog_text.send_message(message)

func _on():
	super._on()
	if ItemManager.player:
		_update_inventory(ItemManager.player.inventory.item_ids)
	else:
		print("Player not found, inventory not updated")

func _on_button_pressed() -> void:
	parent.pop_all()
	GameManager.unpause()
