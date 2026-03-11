class_name ActionHasQuestCompleted extends ActionLeaf

@export var quest_id: String
@export var action_leaf_true: ActionLeaf
@export var action_leaf_false: ActionLeaf

func run() -> void:
	if QuestManager.has_completed_quest(quest_id):
		if action_leaf_true:
			action_leaf_true.run()
	elif action_leaf_false:
		action_leaf_false.run()
