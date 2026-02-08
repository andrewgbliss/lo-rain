class_name BTHasCompletedQuest extends BTNode

@export var quest_id: String

func process(_delta: float) -> Status:
	if QuestManager.has_completed_quest(quest_id):
		return Status.SUCCESS
	return Status.FAILURE
