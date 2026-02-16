class_name BTPlayDialogue extends BTNode

@export var text: String
@export var time: float = 0.0
@export var wait: bool = false

var has_finished: bool = false

func enter():
	has_finished = false
	TextParser.finished.connect(_on_finished)

	var temp_text = text
	if blackboard.get_var("object"):
		temp_text = temp_text.replace("$object", blackboard.get_var("object"))

	#TextParser.send_message(temp_text, time)

func _on_finished():
	has_finished = true
	
func process(_delta: float) -> Status:
	if wait:
		return Status.SUCCESS if has_finished else Status.RUNNING
	else:
		return Status.SUCCESS

func exit():
	TextParser.finished.disconnect(_on_finished)
