class_name CameraPriorityArea2D extends Area2D

@export var camera_priority : int = 20
@export var phantom_camera: PhantomCamera2D

func _ready() -> void:
	connect("body_entered", _entered_body)
	connect("body_exited", _exited_body)

func _entered_body(_body) -> void:
	phantom_camera.set_priority(camera_priority)

func _exited_body(_body) -> void:
	phantom_camera.set_priority(0)
