class_name HeatArea2D extends Area2D

@export var heat_per_second: int = 1

var character: CharacterController
var time_since_last_damage: float = 0.0

func _ready() -> void:
	connect("body_entered", _entered_body)
	connect("body_exited", _exited_body)

func _process(delta: float) -> void:
	if character:
		time_since_last_damage += delta
		if time_since_last_damage >= 0.5:
			character.add_hp(heat_per_second)
			time_since_last_damage = 0.0

func _entered_body(body) -> void:
	if body is CharacterController:
		character = body
		time_since_last_damage = 0.0
		character.is_in_heat_area = true

func _exited_body(body) -> void:
	if body is CharacterController:
		character.is_in_heat_area = false
		character = null
