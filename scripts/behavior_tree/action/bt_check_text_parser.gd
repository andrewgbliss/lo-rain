class_name BTCheckTextParser extends BTNode

@export var text: String

func process(_delta: float) -> Status:
	var command = blackboard.get_var("command")
	print("command", command)
	if command == text:
		return Status.SUCCESS
	else:
		return Status.FAILURE
