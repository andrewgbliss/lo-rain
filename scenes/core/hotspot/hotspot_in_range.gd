class_name HotspotInRange extends Area2D

var in_range
var in_range_body

func _ready():
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)

func on_body_entered(body: Node2D):
	if body is CharacterController:
		in_range = true
		in_range_body = body

func on_body_exited(_body: Node2D):
	in_range = false
	in_range_body = null
