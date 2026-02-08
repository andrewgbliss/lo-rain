extends CanvasLayer

@export var menu_bar_panel : Panel
@export var file_panel : Panel
@export var action_panel : Panel
@export var options_panel : Panel
@export var file_button : Button

var active = false
var is_showing = false

func _ready() -> void:
	menu_bar_panel.hide()
	_hide_all()

func _input(event):
	if not active:
		return
	if event is InputEventKey and event.is_pressed():
		if Input.is_action_just_pressed("pause") and not is_showing:
			_show_menu_bar()
		elif Input.is_action_just_pressed("pause") and is_showing:
			_hide_menu_bar()
			GameManager.unpause()

func _show_menu_bar():
	is_showing = true
	menu_bar_panel.show()
	file_button.grab_focus()
	GameManager.pause()
	
func _hide_menu_bar():
	is_showing = false
	menu_bar_panel.hide()
	_hide_all()
	
func _hide_all():
	file_panel.hide()
	action_panel.hide()
	options_panel.hide()
	
func _show_panel(panel_name: String):
	_hide_all()
	match panel_name:
		"file":
			file_panel.show()
		"action":
			action_panel.show()
		"options":
			options_panel.show()

func _on_save_button_pressed() -> void:
	SaveGameManager.show_save()
	_hide_menu_bar()

func _on_quit_button_pressed() -> void:
	GameManager.quit()

func _on_restore_button_pressed() -> void:
	SaveGameManager.show_restore()
	_hide_menu_bar()

func _on_restart_button_pressed() -> void:
	SaveGameManager.restart()
	_hide_menu_bar()

func _on_action_button_focus_entered() -> void:
	if action_panel.visible:
		action_panel.hide()
	else:
		_show_panel('action')

func _on_options_button_focus_entered() -> void:
	if options_panel.visible:
		options_panel.hide()
	else:
		_show_panel('options')

func _on_file_button_focus_entered() -> void:
	if file_panel.visible:
		file_panel.hide()
	else:
		_show_panel('file')

func _on_sound_button_pressed() -> void:
	_hide_menu_bar()
	MenuManager.push("SettingsMenu")

func _on_inventory_button_pressed() -> void:
	InventoryUI.open()
	_hide_menu_bar()
