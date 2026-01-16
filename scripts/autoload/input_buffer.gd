extends Node
## Input buffer system for fighting game inputs
## Stores recent inputs and allows checking for buffered actions

const BUFFER_WINDOW: int = 8  # frames to buffer inputs

class BufferedInput:
	var action: String
	var frame: int
	var consumed: bool = false
	
	func _init(p_action: String, p_frame: int) -> void:
		action = p_action
		frame = p_frame

var input_history: Array[BufferedInput] = []
var current_frame: int = 0

# Directional state
var move_direction: int = 0  # -1 left, 0 neutral, 1 right
var is_crouching: bool = false

func _physics_process(_delta: float) -> void:
	current_frame += 1
	_update_directional_state()
	_check_button_inputs()
	_clean_old_inputs()

func _update_directional_state() -> void:
	var left = Input.is_action_pressed("move_left")
	var right = Input.is_action_pressed("move_right")
	
	if left and not right:
		move_direction = -1
	elif right and not left:
		move_direction = 1
	else:
		move_direction = 0
	
	is_crouching = Input.is_action_pressed("crouch")

func _check_button_inputs() -> void:
	if Input.is_action_just_pressed("jump"):
		_add_input("jump")
	if Input.is_action_just_pressed("light_attack"):
		_add_input("light_attack")

func _add_input(action: String) -> void:
	var buffered = BufferedInput.new(action, current_frame)
	input_history.append(buffered)

func _clean_old_inputs() -> void:
	var cutoff = current_frame - BUFFER_WINDOW
	input_history = input_history.filter(func(inp): return inp.frame >= cutoff)

func consume_input(action: String) -> bool:
	for inp in input_history:
		if inp.action == action and not inp.consumed:
			inp.consumed = true
			return true
	return false

func has_buffered_input(action: String) -> bool:
	for inp in input_history:
		if inp.action == action and not inp.consumed:
			return true
	return false

func get_direction() -> int:
	return move_direction

func is_holding_crouch() -> bool:
	return is_crouching

func clear_buffer() -> void:
	input_history.clear()
