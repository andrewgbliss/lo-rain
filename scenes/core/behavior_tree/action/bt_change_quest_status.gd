class_name BTChangeQuestStatus extends BTNode

@export var quest_id: String
@export var quest_status: Quest.QuestStatus

func process(_delta: float) -> Status:
	QuestManager.update_quest_status(quest_id, quest_status)
	QuestManager.save()
	return Status.SUCCESS
