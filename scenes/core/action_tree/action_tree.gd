class_name ActionTree extends Node

@export var root_leaf: ActionLeaf
@export var run_after_ready: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if not root_leaf:
		print("ActionTree: No root leaf found")
		return
	call_deferred("_after_ready")
	
func _after_ready() -> void:
	if run_after_ready:
		run()

func run() -> void:
	if root_leaf:
		root_leaf.run()
