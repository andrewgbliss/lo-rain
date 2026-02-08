class_name BTSetMenuBarActive extends BTNode

@export var active: bool = true

func process(_delta: float) -> Status:
	MenuTopBar.active = active
	return Status.SUCCESS
