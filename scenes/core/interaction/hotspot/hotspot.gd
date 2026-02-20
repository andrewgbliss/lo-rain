class_name Hotspot extends Node2D

enum AnimationState {
	None,
	Start,
	InProcess,
	Completed
}

@export var object_name: String
@export var require_in_range: bool = false

@export_category("States")
@export var animation_states: Dictionary[String, AnimationState]
@export var animation_player: AnimationPlayer
@export var play_state_on_load: bool = true

var in_range: bool = false
var in_range_body: CharacterController = null

var parent_room: Room = null
var parent_node: Node2D = null

func _ready():
	parent_node = get_parent()
	parent_room = parent_node.get_parent()
	if not parent_room is Room:
		push_error("Hotspot: Parent node is not a Room")
		return
	hide()
	call_deferred("_after_ready")

func _after_ready():
	var data = GameStateStore.get_hotspot_data(parent_room.room_name, object_name)
	restore(data)
	
func play_animation(state_name: String) -> void:
	var animation_state = animation_states[state_name]
	var animation_state_name = get_animation_name_by_state(animation_state)
	var animation_name = state_name + "_" + animation_state_name
	if animation_player and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)

func set_animation_state(state_name: String, value: String) -> void:
	if animation_states == null:
		animation_states = {}
	var new_state = get_animation_state_by_name(value)
	animation_states[state_name] = new_state
	if new_state != AnimationState.None:
		play_animation(state_name)
	GameStateStore.set_hotspot_data(parent_room.room_name, object_name, save())

func reset_animation_state(state_name: String) -> void:
	if animation_states == null:
		animation_states = {}
	animation_states[state_name] = AnimationState.None

func get_animation_state_by_name(state_name: String) -> AnimationState:
	match state_name:
		"start":
			return AnimationState.Start
		"in_process":
			return AnimationState.InProcess
		"completed":
			return AnimationState.Completed
		_:
			return AnimationState.None

func get_animation_name_by_state(state: AnimationState) -> String:
	match state:
		AnimationState.Start:
			return "start"
		AnimationState.InProcess:
			return "in_process"
		AnimationState.Completed:
			return "completed"
		_:
			return ""

func save() -> Dictionary:
	var data = GameStateStore.get_hotspot_data(parent_room.room_name, object_name)
	if animation_states:
		if not data.has("animation_states"):
			data.animation_states = {}
		for state_name in animation_states:
			data.animation_states[state_name] = get_animation_name_by_state(animation_states[state_name])
	return data

func restore(data: Dictionary) -> void:
	if data == null:
		return
	if data.has("animation_states"):
		for state_name in data.animation_states:
			var value = data.animation_states[state_name]
			if value is String:
				var state = get_animation_state_by_name(value)
				if animation_states == null:
					animation_states = {}
				animation_states[state_name] = state
		if animation_player and play_state_on_load:
			for state_name in animation_states:
				if state_name == "taken" and animation_states[state_name] == AnimationState.Completed:
					return
				if animation_states[state_name] != AnimationState.None:
					show()
					play_animation(state_name)
					return
	show()
