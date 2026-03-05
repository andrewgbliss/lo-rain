class_name RestoreGameMenu extends Menu

@export var save_game_button_container: VBoxContainer
@export var cancel_button_restore: Button

var is_showing: bool = false

func _ready():
	super ()
	cancel_button_restore.pressed.connect(_on_cancel_button_pressed)

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if not is_showing and event.is_action_pressed("restore"):
			_on()
		if is_showing and event.is_action_pressed("ui_cancel"):
			_off()
	
func _on():
	super ()
	is_showing = true
	GameManager.pause()
	var saves = _update_ui()
	if saves.size() == 0:
		cancel_button_restore.grab_focus()
	parent.push(menu_name, false)
	
func _off():
	super ()
	GameManager.unpause()
	is_showing = false
	parent.pop_all(false)

func _update_ui():
	for child in save_game_button_container.get_children():
		child.queue_free()
	var saves = SaveGameManager.get_save_games()
	var first = true
	for s in saves:
		var b = _add_button_to_container(s.index, s.description)
		if first:
			b.grab_focus()
			first = false
	return saves

func _add_button_to_container(index: int, description: String):
	var button = Button.new()
	button.text = description
	button.pressed.connect(func _connect(): _on_restore_game_pressed(index))
	save_game_button_container.add_child(button)
	return button

func _on_cancel_button_pressed() -> void:
	_off()

func _on_restore_game_pressed(index):
	SaveGameManager.restore(index)
