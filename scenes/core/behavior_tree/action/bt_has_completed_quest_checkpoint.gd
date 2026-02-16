class_name BTHasCompletedQuestCheckpoint extends BTNode

@export var quest_id: String
@export var checkpoint_id: String

func process(_delta: float) -> Status:
	if QuestManager.has_completed_checkpoint(quest_id, checkpoint_id):
		return Status.SUCCESS
	return Status.FAILURE
