class_name HotspotInRange extends Area2D

var parent

func _ready():
	parent = get_parent()
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)

func on_body_entered(body: Node2D):
	if body is CharacterController:
		parent.in_range = true
		parent.in_range_body = body

func on_body_exited(_body: Node2D):
	parent.in_range = false
	parent.in_range_body = null
