class_name SceneTransition extends CanvasLayer


@export var animation_transition_in: String = "transition_in"
@export var animation_transition_out: String = "transition_out"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play():
	await transition_in()
	await transition_out()

func transition_in():
	animation_player.play(animation_transition_in)
	await animation_player.animation_finished

func transition_out():
	animation_player.play(animation_transition_out)
	await animation_player.animation_finished
