class_name BTCompleteQuestCheckpoint extends BTNode

@export var quest_id: String
@export var checkpoint_id: String

func process(_delta: float) -> Status:
	QuestManager.complete_checkpoint(quest_id, checkpoint_id)
	return Status.SUCCESS
