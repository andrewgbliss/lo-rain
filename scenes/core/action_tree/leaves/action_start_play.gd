class_name ActionStartPlay extends ActionLeaf

func run() -> void:
	DialogUi.command_prompt.active = true
	GameManager.can_pause = true
	UiManager.hud.show_hud()
	next()
