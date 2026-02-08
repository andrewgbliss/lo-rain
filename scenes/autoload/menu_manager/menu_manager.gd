extends Node

@export var initial_menu: String = "MainMenu"
@export var initial_menu_start_time: float = 0.0
@export var play_game_scene: String = "res://scenes/rooms/long_road.tscn"
@export var play_btn: Button

var menus: Dictionary[String, Node] = {}
var menu_stack: Array[String] = []
var is_transitioning: bool = false

func _ready() -> void:
	for child in get_children():
		if child is Menu:
			menus[child.name] = child
	if GameManager.game_data.show_initial_menu and initial_menu:
		await get_tree().create_timer(initial_menu_start_time).timeout
		push(initial_menu)
		play_btn.grab_focus()
				
func push(menu_name: String):
	if is_transitioning:
		return
	is_transitioning = true
	if menu_stack.size() > 0:
		AudioManager.play("WindSwipeOut")
		await transition_away_out(menu_stack.back())
	menu_stack.append(menu_name)
	AudioManager.play("WindSwipeIn")
	await transition_in(menu_name)
	is_transitioning = false

func pop():
	if is_transitioning:
		return
	is_transitioning = true
	var prev_menu_size = menu_stack.size()
	var menu_name = menu_stack.pop_back()
	AudioManager.play("WindSwipeOut")
	await transition_out(menu_name)
	if prev_menu_size > 1:
		AudioManager.play("WindSwipeIn")
		await transition_away_in(menu_stack.back())
	is_transitioning = false
		
func pop_all():
	if is_transitioning:
		return
	is_transitioning = true
	var menu_name = menu_stack.pop_back()
	if menu_name:
		await transition_out(menu_name)
	menu_stack.clear()
	is_transitioning = false

func transition_in(menu_name: String):
	if menus.has(menu_name):
		await menus[menu_name].transition_in()

func transition_out(menu_name: String):
	if menus.has(menu_name):
		await menus[menu_name].transition_out()

func transition_away_in(menu_name: String):
	if menus.has(menu_name):
		await menus[menu_name].transition_away_in()

func transition_away_out(menu_name: String):
	if menus.has(menu_name):
		await menus[menu_name].transition_away_out()

func _on_back_button_pressed() -> void:
	if is_transitioning:
		return
	AudioManager.play("Click")
	pop()

func _on_play_button_pressed() -> void:
	if is_transitioning:
		return
	AudioManager.play("Click")
	await pop_all()
	await SceneManager.goto_scene(play_game_scene)

func _on_settings_button_pressed() -> void:
	if is_transitioning:
		return
	AudioManager.play("Click")
	push("SettingsMenu")

func _on_quit_button_pressed() -> void:
	if is_transitioning:
		return
	AudioManager.play("Click")
	AudioManager.play("Soundtrack")
	GameManager.quit()

func _on_back_and_un_pause_button_pressed() -> void:
	if is_transitioning:
		return
	AudioManager.play("Click")
	await pop_all()
	GameManager.unpause()

func _on_play_again_button_pressed() -> void:
	if is_transitioning:
		return
	GameManager.unpause()
	AudioManager.play("Click")
	await pop_all()
	AudioManager.play("Soundtrack")
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	if is_transitioning:
		return
	_on_quit_button_pressed()
	#print("main menu button pressed")
	#GameManager.unpause()
	#AudioManager.play("Click")
	#await pop_all()
	#AudioManager.play("Soundtrack")
	#await SceneManager.goto_scene("res://scenes/main.tscn")
	#await get_tree().create_timer(3).timeout
	#push(initial_menu)


func _on_restore_button_pressed() -> void:
	SaveGameManager.show_restore(false)
