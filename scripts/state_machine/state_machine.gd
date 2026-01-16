class_name StateMachine
extends Node
## Generic finite state machine for fighting game characters
## States are child nodes that extend BaseState

signal state_changed(old_state: BaseState, new_state: BaseState)

@export var initial_state: NodePath

var current_state: BaseState
var states: Dictionary = {}

func _ready() -> void:
	await owner.ready
	
	# Register all child states
	for child in get_children():
		if child is BaseState:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.character = owner
	
	# Set initial state
	if initial_state:
		current_state = get_node(initial_state)
	elif states.size() > 0:
		current_state = states.values()[0]
	
	if current_state:
		current_state.enter({})

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _process(delta: float) -> void:
	if current_state:
		current_state.frame_update(delta)

func transition_to(state_name: String, params: Dictionary = {}) -> void:
	var new_state = states.get(state_name.to_lower())
	if not new_state:
		push_warning("State '%s' not found in state machine" % state_name)
		return
	
	if new_state == current_state:
		return
	
	var old_state = current_state
	
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter(params)
	
	state_changed.emit(old_state, new_state)

func get_state(state_name: String) -> BaseState:
	return states.get(state_name.to_lower())

func is_in_state(state_name: String) -> bool:
	if not current_state:
		return false
	return current_state.name.to_lower() == state_name.to_lower()
