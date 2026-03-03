class_name ActionInRange extends ActionLeaf

@export var hotspot_in_range: HotspotInRange
@export var action_leaf_true: ActionLeaf
@export var action_leaf_false: ActionLeaf
@export var show_not_in_range_message: bool = false

func run() -> void:
	if hotspot_in_range.in_range:
		if action_leaf_true:
			action_leaf_true.run()
	else:
		if show_not_in_range_message:
			DialogUi.dialog_text.send_message(TextParser.NotCloseEnough)
			await DialogUi.dialog_text.is_finished
		if action_leaf_false:
			action_leaf_false.run()
