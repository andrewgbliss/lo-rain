class_name ActionEnableHotspot extends ActionLeaf

@export var hotspot: Hotspot
@export var enabled: bool = true

func run() -> void:
	hotspot.enable(enabled)
	next()
