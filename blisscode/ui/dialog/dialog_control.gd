class_name DialogueControl extends Control

@export var label: Label

var message_queue: Array[Dictionary]
var is_running = false
var current_message_time: float = 0
var current_time: float = 0

signal is_started
signal is_finished

func _ready():
	label.visible = false
		
func _input(event):
	if event is InputEventKey and event.is_pressed():
		if is_running and Input.is_action_just_pressed("next_dialogue"):
			_handle_next()
				
func _process(delta):
	if message_queue.size() > 0 and not is_running:
		is_started.emit()
		is_running = true
		_handle_next()
		return
	
	if is_running:
		if current_time > 0:
			current_message_time += delta
			if current_message_time >= current_time:
				_handle_next()
				return
				
func send_message(message: String, time: float = 3.0):
	message_queue.push_back({
		"text": message,
		"time": time
	})

func _handle_next():
	if message_queue.size() == 0:
		label.visible = false
		is_running = false
		is_finished.emit()
		return
	current_message_time = 0
	var next = message_queue.pop_front()
	label.text = next.text
	current_time = next.time
	if not label.visible:
		label.visible = true
