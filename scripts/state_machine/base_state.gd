class_name BaseState
extends Node
## Base class for all character states
## Extend this to create specific states (Idle, Walk, Jump, Attack, etc.)

var state_machine: StateMachine
var character: CharacterBody2D

# Override these in child classes
func enter(_params: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func frame_update(_delta: float) -> void:
	pass

# Called when character takes a hit while in this state
func on_hit(_hit_data: Dictionary) -> void:
	pass

# Called when an animation finishes
func on_animation_finished(_anim_name: String) -> void:
	pass

# Utility: Check if state can be interrupted
func can_be_interrupted() -> bool:
	return true

# Utility: Check if character is grounded
func is_grounded() -> bool:
	if character and character.has_method("is_on_floor"):
		return character.is_on_floor()
	return true
