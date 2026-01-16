class_name DummyHitstunState
extends BaseState
## Training dummy hitstun state - stunned after receiving a hit

var stun_frames: int = 0
var frames_elapsed: int = 0

func enter(params: Dictionary = {}) -> void:
	stun_frames = params.get("hitstun_frames", 12)
	frames_elapsed = 0
	character.play_animation("hitstun")

func physics_update(_delta: float) -> void:
	frames_elapsed += 1
	
	if frames_elapsed >= stun_frames:
		state_machine.transition_to("idle")

func can_be_interrupted() -> bool:
	return false
