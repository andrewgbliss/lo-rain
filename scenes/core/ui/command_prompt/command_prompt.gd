class_name CommandPrompt extends TextEdit

@export var dialog_text: DialogText

var command_stack: Array
var history_index: int = 0
var active: bool = false
var showing: bool = false

signal opened
signal closed

func _ready():
	GameManager.on_pause.connect(_on_pause)
	GameManager.on_unpause.connect(_on_unpause)
	hide()
	
func _on_pause():
	active = false
	
func _on_unpause():
	active = true
	
func is_only_alpha_numeric_pressed(event: InputEventKey):
	return event is InputEventKey and event.is_pressed() and ((event.keycode >= KEY_A and event.keycode <= KEY_Z) or (event.keycode >= KEY_0 and event.keycode <= KEY_9))

func _input(event):
	if not active or dialog_text.is_running:
		return
	if event is InputEventKey and event.is_pressed():
		if not showing and is_only_alpha_numeric_pressed(event):
			_handle_open()
		elif showing and event.keycode == KEY_ENTER:
			_handle_process_command()
		elif event.keycode == KEY_F3:
			_handle_f3()

func _handle_open():
	showing = true
	show()
	grab_focus()
	text = ""
	opened.emit()

func _handle_process_command():
	TextParser.process_command(text)
	command_stack.push_back(text)
	hide()
	showing = false
	closed.emit()

func _handle_f3():
	if not visible:
		if command_stack.size() > 0:
			history_index = command_stack.size() - 1
		else:
			history_index = 0
	else:
		history_index = history_index - 1
		
	if history_index < 0:
		if command_stack.size() > 0:
			history_index = command_stack.size() - 1
		else:
			history_index = 0
		
	if command_stack.size() > 0:
		var command = command_stack[history_index]
		text = command
		set_caret_column(text.length())
		
	if text != "" and not visible:
		showing = true
		show()
		grab_focus()
		opened.emit()
