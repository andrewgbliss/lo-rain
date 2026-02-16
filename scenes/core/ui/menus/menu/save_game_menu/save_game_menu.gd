class_name SaveGameMenu extends Menu

@export var line_edit: LineEdit
@export var save_button: Button
@export var cancel_button_save: Button

var is_showing: bool = false

func _ready():
	super ()
	save_button.pressed.connect(_on_save_button_pressed)
	cancel_button_save.pressed.connect(_on_cancel_button_pressed)
	line_edit.text_changed.connect(_on_line_edit_text_changed)
	line_edit.text_submitted.connect(_on_line_edit_text_submitted)

func _input(event):
		if event is InputEventKey and event.is_pressed() and not event.is_echo():
			if not is_showing and event.is_action_pressed("save"):
				_on()
			if is_showing and event.is_action_pressed("ui_cancel"):
				_off()

func _on():
	super ()
	GameManager.pause()
	is_showing = true
	parent.push(menu_name, false)
	line_edit.grab_focus()
	line_edit.text = ""

func _off():
	super ()
	GameManager.unpause()
	is_showing = false
	parent.pop_all(false)

func _on_save_button_pressed() -> void:
	SaveGameManager.save(line_edit.text)
	_off()
	line_edit.text = ""
	save_button.disabled = true

func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text == "":
		save_button.disabled = true
	else:
		save_button.disabled = false

func _on_line_edit_text_submitted(_new_text: String) -> void:
	_on_save_button_pressed()
	
func _on_cancel_button_pressed() -> void:
	_off()
