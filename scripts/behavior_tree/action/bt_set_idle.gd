class_name BTSetIdle extends BTNode

func process(_delta: float) -> Status:
	agent.set_idle()
	return Status.SUCCESS
