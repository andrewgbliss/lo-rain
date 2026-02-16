class_name HotspotAnimationTrigger extends Area2D

@export var animation_player: AnimationPlayer
@export var animation_name_enter: String = ""
@export var animation_name_exit: String = ""

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(_body):
	if animation_player and animation_name_enter != "":
		animation_player.play(animation_name_enter)

func _on_body_exited(_body):
	if animation_player and animation_name_exit != "":
		animation_player.play(animation_name_exit)
