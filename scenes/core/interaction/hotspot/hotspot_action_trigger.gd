class_name HotspotActionTrigger extends Area2D

@export var action: String
@export var run_action_in_range: bool = false

signal action_run(action: String)

func _ready():
	body_entered.connect(_on_in_range_body_entered)
	body_exited.connect(_on_in_range_body_exited)

func _on_in_range_body_entered(body):
	if body is CharacterController:
		if run_action_in_range:
			action_run.emit(action)

func _on_in_range_body_exited(_body):
	pass
