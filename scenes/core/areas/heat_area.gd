class_name HeatArea2D extends Area2D

func _ready() -> void:
	body_entered.connect(_entered_body)
	body_exited.connect(_exited_body)

func _entered_body(body) -> void:
	if body is CharacterController:
		body.is_in_heat_area = true

func _exited_body(body) -> void:
	if body is CharacterController:
		body.is_in_heat_area = false
