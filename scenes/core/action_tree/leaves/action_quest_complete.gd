class_name ActionQuestComplete extends ActionLeaf

@export var quest_id: String

func run() -> void:
	QuestManager.complete_quest(quest_id)
	next()