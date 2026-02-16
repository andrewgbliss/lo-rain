class_name HotspotDeathTrigger extends Area2D

@export var death_action: String
@export var run_death_action_in_range: bool = false

signal death_action_run(death_action: String)

func _ready():
	body_entered.connect(_on_in_range_body_entered)
	body_exited.connect(_on_in_range_body_exited)

func _on_in_range_body_entered(body):
	if body is CharacterController:
		if run_death_action_in_range:
			death_action_run.emit(death_action)

func _on_in_range_body_exited(_body):
	pass
