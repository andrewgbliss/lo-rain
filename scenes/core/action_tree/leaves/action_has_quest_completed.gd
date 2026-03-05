class_name ActionHasQuestCompleted extends ActionLeaf

@export var quest_id: String
@export var action_leaf_true: ActionLeaf
@export var action_leaf_false: ActionLeaf

func run() -> void:
	if QuestManager.has_completed_quest(quest_id):
		action_leaf_true.run()
	else:
		action_leaf_false.run()
