class_name ActionStartPlay extends ActionLeaf

func run() -> void:
	DialogUi.command_prompt.active = true
	GameManager.can_pause = true
	GameManager.set_state(GameManager.GAME_STATE.GAME_PLAY)
	UiManager.hud.show_hud()
	next()
