class_name IdleState
extends BaseState
## Character idle state - standing still, waiting for input

func enter(_params: Dictionary = {}) -> void:
	character.play_animation("idle")
	character.velocity.x = 0

func physics_update(_delta: float) -> void:
	var player = character as PlayerCharacter
	if not player:
		return
	
	# Check for attack input
	if player.is_attack_buffered():
		player.consume_attack()
		state_machine.transition_to("light_attack")
		return
	
	# Check for jump input
	if player.is_jump_buffered() and is_grounded():
		player.consume_jump()
		state_machine.transition_to("jump")
		return
	
	# Check for movement
	var direction = player.get_input_direction()
	if direction != 0:
		state_machine.transition_to("walk")
		return

func can_be_interrupted() -> bool:
	return true
