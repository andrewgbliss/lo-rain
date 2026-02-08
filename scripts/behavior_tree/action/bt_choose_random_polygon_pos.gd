class_name BTChooseRandomPolygonPos extends BTNode

@export var position_var: StringName = &"pos"
@export var threshold: float = 10.0

func process(_delta: float) -> Status:
	var map = agent.navigation_agent.get_navigation_map()
	if map == null:
		return Status.FAILURE
	var random_point = NavigationServer2D.map_get_random_point(map, 1, false)
	blackboard.set_var(position_var, random_point)
	return Status.SUCCESS
