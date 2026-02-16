class_name QuestUpdateArea extends Area2D

@export var new_status: Quest.QuestStatus
@export var quest_id: String
@export var start_quest_id: String
@export var message: String

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is CharacterController:
		if message:
			TextParser.send_message(message)
		if quest_id and new_status != Quest.QuestStatus.NONE:
			QuestManager.update_quest_status(quest_id, new_status)
		if start_quest_id:
			await get_tree().create_timer(1.0).timeout
			QuestManager.start_quest(start_quest_id)
