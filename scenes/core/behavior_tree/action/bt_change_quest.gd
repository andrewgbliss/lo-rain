class_name BTChangeQuest extends BTNode

@export var quest_id: String

func process(_delta: float) -> Status:
	QuestManager.set_quest(quest_id)
	QuestManager.save()
	return Status.SUCCESS
