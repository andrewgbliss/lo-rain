class_name LookAt extends CharacterActionBase

func _process(_delta: float):
  if not parent.target:
    return
  var direction = (parent.target.global_position - parent.global_position).normalized()
  parent.face_dir(direction)