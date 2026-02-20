class_name NavigationAgentSetTargetPos extends CharacterActionBase

enum TargetPosType {
	Target,
	Random
}

@export var target_pos_type: TargetPosType = TargetPosType.Target
@export var threshold: float = 10.0
@export var wait_time: float = 0.0

var target_pos: Vector2 = Vector2.ZERO
var waiting_time: float = 0.0

func _process(delta: float):
	if parent.navigation_agent == null:
		return

	if target_pos == Vector2.ZERO:
		if waiting_time > 0.0:
			waiting_time -= delta
			return
		if wait_time > 0.0:
			waiting_time = wait_time
		if target_pos_type == TargetPosType.Target:
			_get_target_pos()
		elif target_pos_type == TargetPosType.Random:
			_get_random_point()
	else:
		_has_reached_target_pos()
	
func _has_reached_target_pos():
	if parent.global_position.distance_to(target_pos) < threshold:
		target_pos = Vector2.ZERO

func _get_target_pos():
	target_pos = parent.target.global_position
	parent.navigation_agent.set_target_position(target_pos)

func _get_random_point():
	var map = parent.navigation_agent.get_navigation_map()
	if map == null:
		return
	target_pos = NavigationServer2D.map_get_random_point(map, 1, false)
	parent.navigation_agent.set_target_position(target_pos)