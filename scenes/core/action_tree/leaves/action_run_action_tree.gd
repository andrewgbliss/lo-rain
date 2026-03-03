class_name ActionRunActionTree extends ActionLeaf

@export var action_tree: ActionTree

func run() -> void:
  action_tree.run()
  next()