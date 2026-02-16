class_name BTFindTarget extends BTNode

@export var group: StringName
@export var target_var: StringName = &"target"

var target

func process(_delta: float) -> Status:
	if group == "enemy":
		target = get_enemy_node()
	elif group == "player":
		target = get_player_node()
	blackboard.set_var(target_var, target)
	return Status.SUCCESS
		
func get_enemy_node():
	var nodes = agent.get_tree().get_nodes_in_group(group)
	return nodes[0]
	
func get_player_node():
	var nodes = agent.get_tree().get_nodes_in_group(group)
	return nodes[0]
