class_name ActionNextRandomLeaf extends ActionLeaf

@export var leaves: Array[ActionLeaf]

func run() -> void:
	if leaves.is_empty():
		next()
		return
	var random_index = randi() % leaves.size()
	leaves[random_index].run()
