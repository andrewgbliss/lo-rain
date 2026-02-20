class_name NavigationProcess extends CharacterActionBase

func _process(_delta: float):
	if parent.navigation_agent == null:
		return

	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(parent.navigation_agent.get_navigation_map()) == 0:
		return
		
	if parent.navigation_agent.is_navigation_finished():
		parent._on_velocity_computed(Vector2.ZERO)
		return

	var next_path_position: Vector2 = parent.navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = parent.global_position.direction_to(next_path_position) * parent.move_speed
	if parent.navigation_agent.avoidance_enabled:
		parent.navigation_agent.set_velocity(new_velocity)
	else:
		parent._on_velocity_computed(new_velocity)
