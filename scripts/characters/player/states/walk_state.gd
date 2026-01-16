class_name WalkState
extends BaseState
## Character walking state - horizontal movement

func enter(_params: Dictionary = {}) -> void:
	character.play_animation("walk")

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
	
	# Get movement direction
	var direction = player.get_input_direction()
	
	# Return to idle if no input
	if direction == 0:
		state_machine.transition_to("idle")
		return
	
	# Apply movement
	player.velocity.x = direction * player.move_speed
	player.set_facing(direction)

func exit() -> void:
	character.velocity.x = 0

func can_be_interrupted() -> bool:
	return true
