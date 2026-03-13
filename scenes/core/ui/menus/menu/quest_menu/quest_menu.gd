class_name QuestMenu extends Menu

@export var quest_container: VBoxContainer
@export var close_button: Button

var is_showing: bool = false

func _ready():
	super ()
	close_button.pressed.connect(_on_close)

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if not is_showing and event.is_action_pressed("quest_menu"):
			if not GameManager.is_testing and GameManager.game_state != GameManager.GAME_STATE.GAME_PLAY and GameManager.game_state != GameManager.GAME_STATE.GAME_PAUSED:
				return
			if not GameManager.can_pause:
				return
			_on()
	
func _on():
	super ()
	is_showing = true
	GameManager.pause()
	_update_ui()
	parent.push(menu_name, false)
	
func _off():
	super ()
	GameManager.unpause()
	is_showing = false
	parent.pop_all(false)

func _update_ui():
	for child in quest_container.get_children():
		child.queue_free()
	var quests = QuestManager.get_given_quests()
	for quest in quests:
		_create_quest_entry(quest)
	
func _create_quest_entry(quest: Quest):
	var container = HBoxContainer.new()
	
	var name_label = Label.new()
	name_label.text = quest.quest_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(name_label)

	var status_label = Label.new()
	status_label.text = QuestManager.get_status_text(quest.quest_status)
	container.add_child(status_label)

	var button = Button.new()
	button.text = "View"
	button.pressed.connect(func():
		_show_quest_details(quest)
	)
	container.add_child(button)

	quest_container.add_child(container)
	
func _show_quest_details(quest: Quest):
	var details = "Quest: %s\nDescription: %s" % [quest.quest_name, quest.quest_description]
	_off()
	DialogUi.dialog_text.send_message(details)

func _on_close() -> void:
	_off()
