class_name Quest extends Resource

@export var quest_id: String
@export var quest_name: String
@export var quest_description: String
@export var quest_status: QuestStatus
@export var quest_checkpoints: Dictionary[String, bool]

enum QuestStatus {
	NONE,
	AVAILABLE,
	IN_PROGRESS,
	COMPLETED,
	FAILED
}

func save():
	var data = {
		"quest_id": quest_id,
		"quest_name": quest_name,
		"quest_description": quest_description,
		"quest_status": quest_status,
		"quest_checkpoints": quest_checkpoints
	}
	return data

func restore(data):
	if data.has("quest_id"):
		quest_id = data["quest_id"]
	if data.has("quest_name"):
		quest_name = data["quest_name"]
	if data.has("quest_description"):
		quest_description = data["quest_description"]
	if data.has("quest_status"):
		quest_status = data["quest_status"]
	if data.has("quest_checkpoints"):
		for checkpoint in data["quest_checkpoints"]:
			quest_checkpoints[checkpoint] = data["quest_checkpoints"][checkpoint]
