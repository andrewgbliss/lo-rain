class_name ActionLeaf extends Node

@export var next_leaf: ActionLeaf

func run() -> void:
	pass

func next() -> void:
	if next_leaf:
		next_leaf.run()
