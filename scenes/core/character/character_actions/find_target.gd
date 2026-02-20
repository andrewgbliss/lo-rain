class_name FindTarget extends CharacterActionBase

@export var group: StringName = "player"

func _process(_delta: float):
  if not parent.target:
    parent.target = get_first_node()

func get_first_node():
  var nodes = parent.get_tree().get_nodes_in_group(group)
  return nodes[0]