class_name MenuTopBar extends Menu

@export var menu_bar_panel: Panel
@export var file_panel: Panel
@export var action_panel: Panel
@export var options_panel: Panel
@export var file_button: Button

func _input(event):
	if not GameManager.is_testing and GameManager.game_state != GameManager.GAME_STATE.GAME_PLAY and GameManager.game_state != GameManager.GAME_STATE.GAME_PAUSED:
		return
	if not GameManager.can_pause:
		return
	if event is InputEventKey and event.is_pressed():
		if Input.is_action_just_pressed("pause"):
			if not GameManager.is_paused:
				GameManager.pause()
				UiManager.game_menus.push("MenuTopBar", false)
			else:
				GameManager.unpause()
				UiManager.game_menus.pop()

func _on():
	super ()
	menu_bar_panel.show()
	file_button.grab_focus()

func _off():
	super ()
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
			_focus_first_button(file_panel)
		"action":
			action_panel.show()
			_focus_first_button(action_panel)
		"options":
			options_panel.show()
			_focus_first_button(options_panel)

func _focus_first_button(panel: Panel):
	var first_button = panel.get_node("MarginContainer/VBoxContainer").get_child(0)
	first_button.grab_focus()

func _on_save_button_pressed() -> void:
	_off()
	if GameManager.player != null and not GameManager.player.is_alive:
		DialogUi.dialog_text.send_message("You can't save the game right now.")
		GameManager.unpause()
		UiManager.game_menus.pop()
		return
	UiManager.game_menus.push("SaveGameMenu", false)

func _on_quit_button_pressed() -> void:
	GameManager.quit()

func _on_restore_button_pressed() -> void:
	_off()
	UiManager.game_menus.push("RestoreGameMenu", false)

func _on_restart_button_pressed() -> void:
	_off()
	GameManager.start_new_game()
	SceneManager.goto_first_scene()

func _on_action_button_focus_entered() -> void:
	_show_panel('action')

func _on_options_button_focus_entered() -> void:
	_show_panel('options')

func _on_file_button_focus_entered() -> void:
	_show_panel('file')

func _on_sound_button_pressed() -> void:
	_off()
	UiManager.game_menus.push("SettingsMenu", false)

func _on_inventory_button_pressed() -> void:
	_off()
	UiManager.game_menus.push("InventoryMenu", false)
