class_name ActionCanPause extends ActionLeaf

@export var value: bool

func run() -> void:
	GameManager.can_pause = value
	next()
