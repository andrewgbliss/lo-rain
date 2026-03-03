class_name ActionQuestCompleteCheckpoint extends ActionLeaf

@export var quest_id: String
@export var checkpoint_id: String

func run() -> void:
	QuestManager.complete_checkpoint(quest_id, checkpoint_id)
	next()
