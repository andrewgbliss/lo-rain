class_name BTNavigationProcess extends BTNode

func process(_delta: float) -> Status:
	if agent.navigation_agent == null:
		return Status.FAILURE

	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(agent.navigation_agent.get_navigation_map()) == 0:
		return Status.RUNNING
		
	if agent.navigation_agent.is_navigation_finished():
		agent._on_velocity_computed(Vector2.ZERO)
		return Status.SUCCESS

	var next_path_position: Vector2 = agent.navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = agent.global_position.direction_to(next_path_position) * agent.move_speed
	if agent.navigation_agent.avoidance_enabled:
		agent.navigation_agent.set_velocity(new_velocity)
	else:
		agent._on_velocity_computed(new_velocity)
		
	return Status.RUNNING
