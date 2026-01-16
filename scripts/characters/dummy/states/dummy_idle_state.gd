class_name DummyIdleState
extends BaseState
## Training dummy idle state - just stands there

func enter(_params: Dictionary = {}) -> void:
	character.play_animation("idle")
	character.velocity.x = 0

func physics_update(_delta: float) -> void:
	# Dummy does nothing in idle
	pass

func can_be_interrupted() -> bool:
	return true
