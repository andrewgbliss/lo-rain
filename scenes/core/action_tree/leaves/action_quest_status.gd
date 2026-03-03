class_name ActionQuestStatus extends ActionLeaf

@export var quest_id: String
@export var status_name: String

func run() -> void:
	QuestManager.update_quest_status(quest_id, QuestManager.get_quest_status_by_name(status_name))
	next()