class_name DialogText extends Label

var message_queue: Array[Dictionary]
var is_running = false
var current_message_time: float = 0
var current_time: float = 0

signal is_started
signal is_finished

func _ready():
	hide()

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if is_running and Input.is_action_just_pressed("next_dialogue"):
			_handle_next()
				
func _process(_delta):
	if message_queue.size() > 0 and not is_running:
		is_started.emit()
		is_running = true
		_handle_next()
		return
				
func send_message(message: String):
	message_queue.push_back({
		"text": message
	})

func _handle_next():
	if message_queue.size() == 0:
		hide()
		is_running = false
		is_finished.emit()
		return
	var next = message_queue.pop_front()
	text = next.text
	if not visible:
		show()
