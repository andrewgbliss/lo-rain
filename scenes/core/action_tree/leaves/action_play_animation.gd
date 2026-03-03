class_name ActionPlayAnimation extends ActionLeaf

@export var animation_name: String
@export var animation_player: AnimationPlayer

func run() -> void:
	if animation_player and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
		await animation_player.animation_finished
	next()