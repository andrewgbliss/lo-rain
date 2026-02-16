class_name CharacterControls extends Node

var parent: CharacterController

func _ready():
	parent = get_parent()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_up"):
		parent.change_movement_state(CharacterController.MovementDirection.Up, 0, -1)
	if Input.is_action_just_pressed("move_down"):
		parent.change_movement_state(CharacterController.MovementDirection.Down, 0, 1)
	if Input.is_action_just_pressed("move_left"):
		parent.change_movement_state(CharacterController.MovementDirection.Left, -1, 0)
	if Input.is_action_just_pressed("move_right"):
		parent.change_movement_state(CharacterController.MovementDirection.Right, 1, 0)
	if Input.is_action_just_pressed("move_left_up"):
		parent.change_movement_state(CharacterController.MovementDirection.UpLeft, -1, -1)
	if Input.is_action_just_pressed("move_right_up"):
		parent.change_movement_state(CharacterController.MovementDirection.UpRight, 1, -1)
	if Input.is_action_just_pressed("move_left_down"):
		parent.change_movement_state(CharacterController.MovementDirection.DownLeft, -1, 1)
	if Input.is_action_just_pressed("move_right_down"):
		parent.change_movement_state(CharacterController.MovementDirection.DownRight, 1, 1)
