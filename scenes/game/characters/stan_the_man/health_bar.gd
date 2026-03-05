extends Node2D

@export var texture_rect: TextureRect
@export var label: Label
@export var character: CharacterController

func _ready():
	character.update_hp.connect(_update_texture)
	texture_rect.modulate = Color.RED

func _update_texture(hp: int, max_hp: int) -> void:
	if max_hp <= 0:
		return
	texture_rect.custom_minimum_size.x = hp
	texture_rect.size.x = hp
	var t := float(hp) / float(max_hp)
	var color := Color.RED.lerp(Color.BLUE, 1.0 - t)
	texture_rect.modulate = color
	label.text = str(int(t * 100)) + "o"
