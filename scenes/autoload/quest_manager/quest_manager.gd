extends Node2D

@export_category("Quests")
@export var current_quest_id: String = ""
@export var quests: Array[Quest]

@export_category("UI")
@export var label_name: Label
@export var label_desc: Label
@export var label_status: Label
@export var quest_control: Control
@export var animation_player: AnimationPlayer


func set_quest(quest_id: String):
	current_quest_id = quest_id
	update_ui()

func update_quest_status(quest_id: String, status: Quest.QuestStatus):
	var quest = get_quest_by_id(quest_id)
	quest.quest_status = status
	update_ui()

func get_quest_by_id(quest_id: String):
	for quest in quests:
		if quest.quest_id == quest_id:
			return quest
	return null

func update_ui():
	animation_player.play("show")
	var current_quest = get_quest_by_id(current_quest_id)
	if current_quest:
		label_name.text = current_quest.quest_name
		label_desc.text = current_quest.quest_description
		match current_quest.quest_status:
			Quest.QuestStatus.AVAILABLE:
				label_status.text = "Available"
			Quest.QuestStatus.IN_PROGRESS:
				label_status.text = "In Progress"
			Quest.QuestStatus.COMPLETED:
				label_status.text = "Completed"
			Quest.QuestStatus.FAILED:
				label_status.text = "Failed"
	await get_tree().create_timer(3.0).timeout
	animation_player.play("hide")

func save():
	var data = {
		"current_quest_id": current_quest_id,
		"quests": []
	}
	for quest in quests:
		data["quests"].append(quest.save())
	return data

func restore(data):
	if not data:
		return
	if data.has("quests"):
		quests = []
		for quest_data in data["quests"]:
			var quest = Quest.new()
			quest.restore(quest_data)
			quests.append(quest)
	if data.has("current_quest_id"):
		current_quest_id = data["current_quest_id"]
	update_ui()

func reset():
	for quest in quests:
		quest.quest_status = Quest.QuestStatus.NONE
		for checkpoint in quest.quest_checkpoints:
			quest.quest_checkpoints[checkpoint] = false
	current_quest_id = ""
	update_ui()

func start_quest(quest_id: String):
	current_quest_id = quest_id
	var quest = get_quest_by_id(quest_id)
	quest.quest_status = Quest.QuestStatus.IN_PROGRESS
	update_ui()
	
func complete_quest(quest_id: String):
	var quest = get_quest_by_id(quest_id)
	quest.quest_status = Quest.QuestStatus.COMPLETED
	update_ui()

func fail_quest(quest_id: String):
	var quest = get_quest_by_id(quest_id)
	quest.quest_status = Quest.QuestStatus.FAILED
	update_ui()

func complete_checkpoint(quest_id: String, checkpoint_id: String):
	var quest = get_quest_by_id(quest_id)
	quest.quest_checkpoints[checkpoint_id] = true
	update_ui()

func has_completed_quest(quest_id: String):
	var quest = get_quest_by_id(quest_id)
	return quest.quest_status == Quest.QuestStatus.COMPLETED

func has_completed_checkpoint(quest_id: String, checkpoint_id: String):
	var quest = get_quest_by_id(quest_id)
	return quest.quest_checkpoints[checkpoint_id] == true
