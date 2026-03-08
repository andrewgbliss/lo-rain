class_name ActionLeaf extends Node

@export var next_leaf: ActionLeaf

func run() -> void:
	pass

func next() -> void:
	if next_leaf:
		if GameManager.is_sleeping:
			await GameManager.sleep_finished
		next_leaf.run()
