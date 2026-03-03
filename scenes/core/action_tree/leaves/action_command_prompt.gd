class_name ActionCommandPrompt extends ActionLeaf

@export var active: bool

func run() -> void:
	DialogUi.command_prompt.active = active
	next()
