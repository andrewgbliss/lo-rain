class_name HotspotAnimationTrigger extends Area2D

@export var animation_name_enter: String = ""
@export var animation_name_exit: String = ""

var parent

func _ready():
	parent = get_parent()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func is_animation_completed(animation_name: String) -> bool:
	return parent.animation_states.has(animation_name) and parent.animation_states[animation_name] == Hotspot.AnimationState.Completed

func _on_body_entered(_body):
	if is_animation_completed(animation_name_enter):
		return
	if parent.animation_player and animation_name_enter != "":
		parent.set_animation_state(animation_name_enter, "start")

func _on_body_exited(_body):
	if is_animation_completed(animation_name_exit):
		return
	if parent.animation_player and animation_name_exit != "":
		parent.set_animation_state(animation_name_exit, "start")
