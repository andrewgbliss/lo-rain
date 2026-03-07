class_name ActionShowNode2D extends ActionLeaf

@export var node2d: Node2D
@export var show: bool

func run() -> void:
	if node2d:
		node2d.visible = show
	next()
