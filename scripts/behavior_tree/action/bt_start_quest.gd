class_name BTStartQuest extends BTNode

@export var quest_id: String

func process(_delta: float) -> Status:
	QuestManager.start_quest(quest_id)
	return Status.SUCCESS
