class_name Menu extends Node2D

@export var canvas_layer: CanvasLayer
@export var animation_transition_in: String = "transition_in"
@export var animation_transition_out: String = "transition_out"
@export var animation_transition_away_in: String = "transition_away_in"
@export var animation_transition_away_out: String = "transition_away_out"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	if canvas_layer:
		canvas_layer.hide()

func transition_in():
	if canvas_layer:
		canvas_layer.show()
	animation_player.play(animation_transition_in)
	await animation_player.animation_finished

func transition_out():
	animation_player.play(animation_transition_out)
	await animation_player.animation_finished
	if canvas_layer:
		canvas_layer.hide()

func transition_away_in():
	if canvas_layer:
		canvas_layer.show()
	animation_player.play(animation_transition_away_in)
	await animation_player.animation_finished
	
func transition_away_out():
	animation_player.play(animation_transition_away_out)
	await animation_player.animation_finished
	if canvas_layer:
		canvas_layer.hide()
