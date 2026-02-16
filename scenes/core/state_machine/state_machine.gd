class_name StateMachine extends Node

@export var initial_state : State

var current_state : State
var states : Dictionary = {}
var transitions : Dictionary = {}

signal active_state_changed

func init(parent) -> void:
	for child in get_children():
		child.parent = parent
		child.state_machine = self
		states[child.name] = child
	if initial_state:
		change_state(initial_state)
		
func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	if current_state:
		current_state.exit()
	active_state_changed.emit(new_state, current_state)
	current_state = new_state
	current_state.enter()
	
func process_input(event: InputEvent) -> void:
	current_state.process_input(event)

func process_frame(delta: float) -> void:
	current_state.process_frame(delta)

func process_physics(delta: float) -> void:
	current_state.process_physics(delta)
		
func dispatch(transition_name: String):
	if not transitions.has(transition_name):
		return
	var states = transitions[transition_name]
	var state_a = states[0]
	var state_b = states[1]
	if state_a:
		state_a.exit()
	active_state_changed.emit(state_b, state_a)
	current_state = state_b
	current_state.enter()
	
func add_transition(state_a: State, state_b: State, transition_name: String):
	if transitions.has(transition_name):
		return
	transitions[transition_name] = [state_a, state_b]
	
func get_active_state():
	return current_state
