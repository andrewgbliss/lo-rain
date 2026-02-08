extends Node2D

@export var texture_rect: TextureRect
@export var label: Label
@export var character: CharacterController

var total = 35

func _ready():
	character.update_hp.connect(_update_texture)
	texture_rect.modulate = Color.RED

func _update_texture(amount: int):
	texture_rect.custom_minimum_size.x = amount
	texture_rect.size.x = amount
	
	# Calculate color based on health amount
	var t = float(amount) / total # Get percentage between 0 and 1
	var color = Color.RED.lerp(Color.BLUE, 1.0 - t) # Lerp from red to blue
	texture_rect.modulate = color
	label.text = str(int(t * 100)) + "o"
