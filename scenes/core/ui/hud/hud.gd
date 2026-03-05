class_name Hud extends Node

@export var cold_meter: TextureRect
@export var health_bar_max_width: int = 25

func _ready() -> void:
	hide_hud()

func show_hud():
	cold_meter.show()

func hide_hud():
	cold_meter.hide()

func update_health_bar(hp: int, max_hp: int) -> void:
	var mat := cold_meter.material as ShaderMaterial
	if mat and max_hp > 0:
		mat.set_shader_parameter("hp", float(hp) / float(max_hp))
		var width := int((float(hp) / float(max_hp)) * health_bar_max_width)
		cold_meter.custom_minimum_size.x = width
		cold_meter.size.x = width
