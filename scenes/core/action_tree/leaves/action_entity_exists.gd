class_name ActionEntityExists extends ActionLeaf

@export var entity_name: String
@export var action_leaf_true: ActionLeaf
@export var action_leaf_false: ActionLeaf

func run() -> void:
	var entity = SpawnManager.get_spawned_entity(entity_name)
	if entity != null and action_leaf_true:
		action_leaf_true.run()
	elif action_leaf_false:
		action_leaf_false.run()
