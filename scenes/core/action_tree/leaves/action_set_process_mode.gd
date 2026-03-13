class_name ActionSetProcessMode extends ActionLeaf

@export var node: Node
@export var set_mode: ProcessMode

func run() -> void:
	node.process_mode = set_mode
	next()
