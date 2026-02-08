extends Control

@export var text_prompt: Control
@export var text: TextEdit
@export var dialog_control: DialogueControl

enum DialogState {Default, Text, Dialogue}

var dialog_state: DialogState = DialogState.Default
var command_stack: Array
var history_index: int = 0
var active: bool = true
var not_visible_time: float = 0.0

signal opened
signal closed
signal finished

func _ready():
	dialog_control.is_finished.connect(_handle_dialogue_finished)
	dialog_state = DialogState.Default
	text_prompt.visible = false
	TextParser.send_message.connect(_on_send_message)
	GameManager.on_pause.connect(_on_pause)
	GameManager.on_unpause.connect(_on_unpause)

func _on_send_message(s: String):
	dialog_control.send_message(s)
	
func _on_pause():
	active = false
	
func _on_unpause():
	active = true
	
func _handle_dialogue_finished():
	dialog_state = DialogState.Default
	finished.emit()
	
func is_only_alpha_numeric_pressed(event: InputEventKey):
	return event is InputEventKey and event.is_pressed() and ((event.keycode >= KEY_A and event.keycode <= KEY_Z) or (event.keycode >= KEY_0 and event.keycode <= KEY_9))

func _input(event):
	if not active:
		return
	if event is InputEventKey and event.is_pressed():
		if dialog_state == DialogState.Default and is_only_alpha_numeric_pressed(event):
			_handle_open()
		elif dialog_state == DialogState.Text and event.keycode == KEY_ENTER:
			_handle_process_command()
		elif dialog_state == DialogState.Default and event.keycode == KEY_F3:
			_handle_f3()

func _handle_open():
	opened.emit()
	text_prompt.visible = true
	text.grab_focus()
	text.text = ""
	dialog_state = DialogState.Text
	opened.emit()

func _handle_process_command():
	dialog_state = DialogState.Dialogue
	if text.text:
		TextParser.process_command(text.text)
	else:
		dialog_state = DialogState.Default
	text_prompt.visible = false
	closed.emit()

func _handle_f3():
	if not text_prompt.visible:
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
		text.text = command
		text.set_caret_column(text.text.length())
		dialog_state = DialogState.Text
		
	if text.text != "" and not text_prompt.visible:
		text_prompt.visible = true
		text.grab_focus()
	
func send_message(s: String, time: float = 0.0):
	dialog_control.send_message(s, time)
