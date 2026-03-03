class_name ActionQuestStart extends ActionLeaf

@export var quest_id: String

func run() -> void:
	QuestManager.start_quest(quest_id)
	next()