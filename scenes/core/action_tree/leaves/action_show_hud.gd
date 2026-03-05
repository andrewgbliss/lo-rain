class_name ActionShowHud extends ActionLeaf

@export var show: bool

func run() -> void:
	if show:
		UiManager.hud.show_hud()
	else:
		UiManager.hud.hide_hud()
	
