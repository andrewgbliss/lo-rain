class_name ActionHasText extends ActionLeaf

@export var text: String = ""
@export var text_to_find: String = ""
@export var action_leaf_true: ActionLeaf
@export var action_leaf_false: ActionLeaf

func run() -> void:
	if text.find(text_to_find) == -1:
		action_leaf_false.run()
	else:
		action_leaf_true.run()
