class_name CharacterController extends CharacterBody2D

enum CharacterType {Player, NPC}
enum MovementDirection {None, Up, Down, Left, Right, UpLeft, UpRight, DownLeft, DownRight}
enum MovementState {Idle, Walking}

@export var character_type: CharacterType
@export var show_sprite_on_ready: bool = true
@export var paralyzed: bool = false
@export var has_gravity: bool = true
@export var inventory: Inventory

@export_category("Movement")
@export var move_speed: Vector2 = Vector2(40, 20)
@export var default_movement_direction: MovementDirection = MovementDirection.None

@export_category("Animation")
@export var animation_idle_right: String = "IdleRight"
@export var animation_idle_up: String = "IdleUp"
@export var animation_idle_down: String = "IdleDown"
@export var animation_walk_right: String = "WalkRight"
@export var animation_walk_up: String = "WalkUp"
@export var animation_walk_down: String = "WalkDown"

@export_category("Health")
@export var hp: int = 35
@export var max_hp: int = 35

@export_category("Navigation")
@export var navigation_agent: NavigationAgent2D

@export_category("Scale")
@export var use_scale_factor: bool = false
@export var scale_factor: float = 100.0
@export var scale_factor_min: float = 0.5
@export var scale_factor_max: float = 2.0

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var movement_direction = MovementDirection.Down
var movement_state = MovementState.Idle
var input: Vector2 = Vector2(40, 40)
var is_facing_right: bool = true

var timer: Timer
var is_in_heat_area: bool = false
var target

signal update_hp(amount: int)

func _ready():
	if show_sprite_on_ready:
		sprite.visible = true
	else:
		sprite.visible = false
	timer = Timer.new()
	timer.wait_time = .5
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()
	if default_movement_direction != MovementDirection.None:
		change_movement_state(default_movement_direction, 0, 0)
		
	if navigation_agent:
		navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
		
func set_scale_by_y_position():
	# Get the current Y position
	var y_position = global_position.y

	# Calculate the scale factor (example: growing as Y increases)
	var factor = 1.0 + (y_position / scale_factor) # Reversed from subtraction to addition

	# Clamp the scale factor to a reasonable range (e.g., 0.5 to 2.0)
	factor = clamp(factor, scale_factor_min, scale_factor_max)

	# Apply the scale factor to the player's Y scale
	self.scale.y = factor if self.scale.y >= 0 else factor * -1
	self.scale.x = factor if self.scale.x >= 0 else factor * -1

func _on_text_parser_opened():
	paralyzed = true
	
func _on_text_parser_closed():
	paralyzed = false
	
func _on_timer_timeout():
	if not is_in_heat_area:
		add_hp(-1)
		
func _physics_process(delta):
	if has_gravity:
		velocity += get_gravity() * delta

	if move_and_slide():
		_handle_collisions()
		
	_handle_flip()

	if use_scale_factor:
		set_scale_by_y_position()
	
func _handle_collisions():
	#movement_state = MovementState.Idle
	#input.x = 0
	#input.y = 0
	#velocity.x = 0
	#velocity.y = 0
	#update_animations()
	pass
	
func _handle_flip():
	# handle flip facing towards
	if movement_direction == MovementDirection.Left:
		scale.x = scale.y * -1
		is_facing_right = false
		return
	scale.x = scale.y * 1
	is_facing_right = true
		
func set_idle(move_direction: MovementDirection = MovementDirection.None):
	movement_direction = move_direction
	movement_state = MovementState.Idle
	input.x = 0
	input.y = 0
	velocity.x = 0
	velocity.y = 0
	update_animations()
	
func set_idle_same_dir():
	movement_state = MovementState.Idle
	input.x = 0
	input.y = 0
	velocity.x = 0
	velocity.y = 0
	update_animations()

func change_movement_state(move_direction: MovementDirection, x: float, y: float):
	if paralyzed:
		return
	if (move_direction != movement_direction):
		movement_state = MovementState.Walking
		input.x = x
		input.y = y
		movement_direction = move_direction
	elif (movement_state == MovementState.Walking):
		movement_state = MovementState.Idle
		input.x = 0
		input.y = 0
	else:
		movement_state = MovementState.Walking
		input.x = x
		input.y = y
		movement_direction = move_direction
	velocity.x = input.x * move_speed.x
	velocity.y = input.y * move_speed.y
	update_animations()
	
func update_animations():
	# if has velocity
	if velocity.length() > 0:
		match movement_direction:
			MovementDirection.Up:
				animation_player.play(animation_walk_up)
			MovementDirection.Down:
				animation_player.play(animation_walk_down)
			MovementDirection.Left:
				animation_player.play(animation_walk_right)
			MovementDirection.Right:
				animation_player.play(animation_walk_right)
			MovementDirection.UpLeft:
				animation_player.play(animation_walk_up)
			MovementDirection.UpRight:
				animation_player.play(animation_walk_up)
			MovementDirection.DownLeft:
				animation_player.play(animation_walk_down)
			MovementDirection.DownRight:
				animation_player.play(animation_walk_down)
			_:
				animation_player.play(animation_walk_right)
	else:
		match movement_direction:
			MovementDirection.Up:
				animation_player.play(animation_idle_up)
			MovementDirection.Down:
				animation_player.play(animation_idle_down)
			MovementDirection.Left:
				animation_player.play(animation_idle_right)
			MovementDirection.Right:
				animation_player.play(animation_idle_right)
			MovementDirection.UpLeft:
				animation_player.play(animation_idle_up)
			MovementDirection.UpRight:
				animation_player.play(animation_idle_up)
			MovementDirection.DownLeft:
				animation_player.play(animation_idle_down)
			MovementDirection.DownRight:
				animation_player.play(animation_idle_down)
			_:
				animation_player.play(animation_idle_right)


func add_hp(amount):
	hp += amount
	if hp > max_hp:
		hp = max_hp
	update_hp.emit(hp)
	if hp <= 0:
		timer.stop()
		print("You Dead!")

func spawn(pos: Vector2 = position):
	position = pos
	set_idle(movement_direction)
	sprite.visible = true
	paralyzed = false
	if movement_direction == MovementDirection.Left:
		scale.x = scale.y * -1
	elif movement_direction == MovementDirection.Right:
		scale.x = scale.y * 1
	
func spawn_restore():
	velocity.x = 0
	velocity.y = 0
	update_animations()
	sprite.visible = true
	paralyzed = false
	if movement_direction == MovementDirection.Left:
		scale.x = scale.y * -1
	elif movement_direction == MovementDirection.Right:
		scale.x = scale.y * 1

func spawn_random():
	if navigation_agent:
		var map = navigation_agent.get_navigation_map()
		if map == null:
			return
		var random_point = NavigationServer2D.map_get_random_point(map, 1, false)
		spawn(random_point)
	else:
		spawn(position)

func face_dir(dir: Vector2):
	# Calculate angle of direction vector
	var angle = atan2(dir.y, dir.x)
	
	# Convert angle to 8-way direction
	if angle < -7 * PI / 8:
		movement_direction = MovementDirection.Left
	elif angle < -5 * PI / 8:
		movement_direction = MovementDirection.UpLeft
	elif angle < -3 * PI / 8:
		movement_direction = MovementDirection.Up
	elif angle < -PI / 8:
		movement_direction = MovementDirection.UpRight
	elif angle < PI / 8:
		movement_direction = MovementDirection.Right
	elif angle < 3 * PI / 8:
		movement_direction = MovementDirection.DownRight
	elif angle < 5 * PI / 8:
		movement_direction = MovementDirection.Down
	elif angle < 7 * PI / 8:
		movement_direction = MovementDirection.DownLeft
	else:
		movement_direction = MovementDirection.Left

	if movement_direction == MovementDirection.Left:
		scale.x = scale.y * -1
	else:
		scale.x = scale.y * 1
	
	# Update animations based on new movement direction
	update_animations()

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	_calculate_movement_direction_from_velocity()
	update_animations()

func _calculate_movement_direction_from_velocity():
	if velocity.length() < 0.1:
		movement_direction = MovementDirection.None
		return
		
	var x = velocity.x
	var y = velocity.y
	
	# Calculate angle of velocity vector
	var angle = atan2(y, x)
	
	# Convert angle to 8-way direction
	if angle < -7 * PI / 8:
		movement_direction = MovementDirection.Left
	elif angle < -5 * PI / 8:
		movement_direction = MovementDirection.UpLeft
	elif angle < -3 * PI / 8:
		movement_direction = MovementDirection.Up
	elif angle < -PI / 8:
		movement_direction = MovementDirection.UpRight
	elif angle < PI / 8:
		movement_direction = MovementDirection.Right
	elif angle < 3 * PI / 8:
		movement_direction = MovementDirection.DownRight
	elif angle < 5 * PI / 8:
		movement_direction = MovementDirection.Down
	elif angle < 7 * PI / 8:
		movement_direction = MovementDirection.DownLeft
	else:
		movement_direction = MovementDirection.Left

func get_movement_direction_by_int(i: int) -> MovementDirection:
	match i:
		0:
			return MovementDirection.None
		1:
			return MovementDirection.Up
		2:
			return MovementDirection.Down
		3:
			return MovementDirection.Left
		4:
			return MovementDirection.Right
		5:
			return MovementDirection.UpLeft
		6:
			return MovementDirection.UpRight
		7:
			return MovementDirection.DownRight
		_:
			return MovementDirection.None

func save():
	var data = {
		"filename": get_scene_file_path(),
		"path": get_path(),
		"parent": get_parent().get_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"input_x": input.x,
		"input_y": input.y,
		"movement_direction": int(movement_direction),
		"movement_state": int(movement_state),
		"is_facing_right": is_facing_right
	}
	return data
	
func restore(data):
	if data.get("is_facing_right"):
		is_facing_right = data.get("is_facing_right")
	if data.get("input_x"):
		input.x = data.get("input_x")
	if data.get("input_y"):
		input.y = data.get("input_y")
	if data.get("movement_direction"):
		movement_direction = int(data.get("movement_direction")) as MovementDirection
	if data.get("movement_state"):
		movement_state = int(data.get("movement_state")) as MovementState
