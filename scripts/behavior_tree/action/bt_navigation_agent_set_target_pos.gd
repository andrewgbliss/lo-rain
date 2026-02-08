class_name BTNavigationAgentSetTargetPos extends BTNode

@export var position_var: StringName = &"pos"

func process(_delta: float) -> Status:
	if agent.navigation_agent == null:
		return Status.FAILURE
		
	var target_pos = blackboard.get_var(position_var)
	if target_pos == null:
		return Status.FAILURE
	
	agent.navigation_agent.set_target_position(target_pos)
	return Status.SUCCESS
