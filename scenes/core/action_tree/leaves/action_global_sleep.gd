class_name ActionGlobalSleep extends ActionLeaf

@export var duration: float = 1.0

func run() -> void:
	GameManager.is_sleeping = true
	await get_tree().create_timer(duration).timeout
	GameManager.is_sleeping = false
	GameManager.sleep_finished.emit()
	next()
