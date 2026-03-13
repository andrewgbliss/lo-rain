class_name ActionSetVisible extends ActionLeaf

@export var node: Node
@export var visible: bool = true

func run() -> void:
	node.visible = visible
	next()