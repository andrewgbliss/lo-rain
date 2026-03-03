class_name HotspotActionTrigger extends Area2D

@export var action_tree_enter: ActionTree
@export var action_tree_exit: ActionTree
@export var enter_times: int = -1
@export var exit_times: int = -1

func _ready():
	body_entered.connect(_on_in_range_body_entered)
	body_exited.connect(_on_in_range_body_exited)

func _on_in_range_body_entered(_body):
	if not action_tree_enter:
		return
	if enter_times == -1:
		action_tree_enter.run()
	elif enter_times > 0:
		enter_times = enter_times - 1
		action_tree_enter.run()

func _on_in_range_body_exited(_body):
	if not action_tree_exit:
		return
	if exit_times == -1:
		action_tree_exit.run()
	elif exit_times > 0:
		exit_times = exit_times - 1
		action_tree_exit.run()
