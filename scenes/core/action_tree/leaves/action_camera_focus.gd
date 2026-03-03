class_name ActionCameraFocus extends ActionLeaf

@export var entity_name: String
@export var camera: Camera2D
@export var phantom_camera: PhantomCamera2D

func run() -> void:
	var entity = SpawnManager.get_spawned_entity(entity_name)
	if entity == null:
		next()
		return
	if phantom_camera:
		if entity is Node2D:
			phantom_camera.follow_mode = PhantomCamera2D.FollowMode.FRAMED
			phantom_camera.follow_target = entity as Node2D
			phantom_camera.follow_damping = false
			phantom_camera.set_priority(20)
	if camera:
		camera.enabled = true
		camera.make_current()
	await get_tree().create_timer(0.1).timeout
	if phantom_camera:
		phantom_camera.follow_damping = true
		phantom_camera.dead_zone_width = 0.25
		phantom_camera.dead_zone_height = 0.25
	next()
